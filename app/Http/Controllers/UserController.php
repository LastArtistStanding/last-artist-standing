<?php

namespace App\Http\Controllers;

use App\Follow;
use App\Submission;
use App\User;
use App\Streak;
use Carbon\Carbon;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    function index() {
        return User::withCount('submissions')->get();
    }

    public function show($id) {
        $user = User::where('id', $id)
            ->with(['streak', 'badges.badge', 'highlights.submission'])
            ->firstOrFail();

        //$user->unearned_badges = Badge::whereRaw('badges.id NOT IN ( SELECT badge_id FROM user_badges WHERE user_id = ' . $user->id)->get();
        $user->locked_badges = DB::select(
            DB::raw("SELECT * FROM badges WHERE badges.id NOT IN (SELECT badge_id FROM user_badges WHERE user_id = " . $user->id . ")")
        );

        $submission_counts = Submission::select(DB::raw('count(*) as count, SUBSTRING(DATE(created_at),1,7) as date'))
            ->where('user_id', '=', $user->id)
            ->groupBy(DB::raw('YEAR(created_at), MONTH(created_at)'))
            ->get();

        foreach($submission_counts as $count) {
            $date = Carbon::parse($count->date);
            $count->title = date('F', strtotime("2000-$date->month-01")) . ' ' . $date->year;
        }

        $user->submission_counts = $submission_counts;

        $user->total_submissions = Submission::where('user_id', '=', $user->id)->count();

        return $user;
    }

    public function getSubmissionsFromDate($id, Request $request) {
        if (!$request->date) {
            return response()->json(['error' => ['No date provided']], 422);
        }

        try {
            Carbon::parse($request->date);
        } catch(Exception $e) { return response()->json(['error' => ['No date provided']], 422); }

        $submissions = Submission::whereRaw('user_id = ' . $id . ' AND SUBSTRING(DATE(created_at),1,7) = \'' . $request->date . '\'')
            ->get();

        return $submissions;
    }

    public function streak($id) {
        $streak = Streak::where('user_id', $id)->with('user')->firstOrFail();
        return $streak;
    }

    public function submissions($id) {
        $user = User::where('id', $id)->firstOrFail();

        $limit = request()->input('limit');

        if ($limit) {
        $user->submissions = Submission::where('user_id', $user->id)
            ->orderBy('id', 'desc')
            ->take($limit)
            ->get();
        } else {
            $user->submissions = $user->submissions()->get();
        }
        return $user;
    }

    public function getFollows() {
        return Auth::user()->follows;
    }

    public function toggleFollow(Request $request) {
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'user_id' => 'required|numeric|exists:users,id'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $existing = Follow::where([['user_id', '=', $user->id], ['target_user_id', '=', $request->user_id]])->first();

        if ($existing) {
            $result = $existing->delete();
            if (!$result) {
                $target_username = User::find($request->input('user_id'))->username;
                return response()->json(['error' => ['Failed to unfollow \'' . $target_username . '\'.']], 500);
            } else {
                return $user->follows;
            }
        } else {
            $follow = new Follow();
            $follow->user_id = $user->id;
            $follow->target_user_id = $request->user_id;
            $result = $follow->save();
            if (!$result) {
                $target_username = User::find($request->input('user_id'))->username;
                return response()->json(['error' => ['Failed to follow \'' . $target_username . '\'.']], 500);
            } else {
                return $user->follows;
            }
        }
    }
}
