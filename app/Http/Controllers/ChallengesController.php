<?php

namespace App\Http\Controllers;

use App\Challenge;
use App\ChallengeEntry;
use App\ChallengeVote;
use Carbon\Carbon;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ChallengesController extends Controller
{
    public function index() {
        $challenges = Challenge::select(DB::raw('challenges.*, count(challenge_entries.challenge_id) as entry_count'))
            ->leftJoin('challenge_entries', 'challenge_entries.challenge_id', '=', 'challenges.id')
            ->groupBy('challenges.id')
            ->with('user')
            ->get();

        foreach($challenges as $challenge) {
            $challenge->end_date = Carbon::parse($challenge->created_at)->addDays($challenge->duration);
        }

        return $challenges;
    }

    public function vote(Request $request, $id) {
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'entry_id' => 'required|integer|exists:challenge_entries,id'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $challenge = Challenge::where('id', $id)->first();
        if ($challenge->status != 'voting') {
            return response()->json(['error' => ['You can\'t vote for a challenge not in voting mode.']], 401);
        }

        $existingVote = ChallengeVote::where(['user_id' => $user->id, 'challenge_id' => $id])->first();

        if ($existingVote) {
            $existingVote->voted_for = $request->entry_id;
            $existingVote->save();

            return $existingVote;
        } else {
            $challengeVote = new ChallengeVote([
                'voted_for' => $request->entry_id
            ]);
            $challengeVote->user_id = $user->id;
            $challengeVote->challenge_id = $id;
            $challengeVote->save();

            return $challengeVote;
        }
    }

    public function myVote($id) {
        $user = Auth::user();

        return ChallengeVote::where(['user_id' => $user->id, 'challenge_id' => $id])->first();
    }

    public function winner($id) {
        $winner = ChallengeVote::select('voted_for', DB::raw('count(*) as votes'))
            ->where('challenge_id', '=', $id)
            ->groupBy('voted_for')
            ->orderBy('votes', 'DESC')
            ->firstOrFail();

        $entry = ChallengeEntry::where('id', '=', $winner->voted_for)->with(['user', 'submission'])->firstOrFail();
        $entry->votes = $winner->votes;

        return $entry;
    }

    public function show($id) {
        $challenge = Challenge::where('id', $id)
            ->with([
                'user',
                'entries.submission',
                'entries.user'
            ])
            ->firstOrFail();

        $challenge->rules = json_encode(explode("\n", $challenge->rules));

        $challenge->end_date = Carbon::parse($challenge->created_at)->addDays($challenge->duration);

        return $challenge;
    }

    public function active() {
        $challenges = Challenge::where('status', '=', 'active')
            ->with('user')
            ->get();

        foreach($challenges as $challenge) {
            $challenge->end_date = Carbon::parse($challenge->created_at)->addDays($challenge->duration);
        }

        return $challenges;
    }

    public function store(Request $request) {
        $user =  Auth::user();

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:50',
            'duration' => 'required|integer|min:0|max:31',
            'description' => 'required|string|max:1000',
            'rules' => 'required|string|max:3000',
            'contest' => 'required|boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $challenge = new Challenge([
            'title' => $request->title,
            'duration' => $request->duration,
            'description' => $request->description,
            'rules' => $request->rules,
            'contest' => $request->contest
        ]);

        $challenge->user_id = $user->id;
        $challenge->status = 'active';

        $challenge->save();
        $challenge->user;
        $challenge->end_date = Carbon::parse($challenge->created_at)->addDays($challenge->duration);

        return $challenge;
    }

    public function update($id) {
        $user = Auth::user();

        $challenge = Challenge::where('id', $id)->firstOrFail();

        if ($challenge->user_id != $user->id) {
            return response()->json(['error' => ['You can only edit your own challenges']], 401);
        }

        $validator = Validator::make(request()->all(), [
            'title' => 'required|string|max:50',
            'description' => 'required|string|max:1000',
            'rules' => 'required|string|max:3000'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $result = $challenge->update([
            'title' => request()->title,
            'description' => request()->description,
            'rules' => request()->rules
        ]);

        if ($result) {
            $challenge->user;
            $challenge->rules = json_encode(explode("\n", $challenge->rules));
            return $challenge;
        } else {
            return response()->json(['error' => ['Failed to update challenge.']], 500);
        }
    }

    public function end() {
        // End challenges that's done with its duration
        $challenges = Challenge::whereRaw("DATE(created_at) = DATE_SUB(UTC_DATE(), INTERVAL duration + 1 day) AND status = 'active'")
            ->get();

        foreach ($challenges as $challenge) {
            if ($challenge->contest) { // Set it into voting mode if it's a contest
                if (sizeof($challenge->entries) > 1) {
                    $challenge->status = 'voting';
                } else {
                    $challenge->status = 'inactive'; // Nobody or just one person entered; No voting, no winner.
                }
            } else {
                $challenge->status = 'inactive';
            }

            $challenge->save();
        }

        // End challenges that's been voting for 2 days
        $challenges_voting = Challenge::whereRaw('DATE(created_at) = DATE_SUB(UTC_DATE(), INTERVAL duration + 3 day) AND status = \'voting\'')
            ->get();

        foreach ($challenges_voting as $challenge_voting) {
            $challenge_voting->status = 'inactive';

            $challenge_voting->save();
        }
    }
}
