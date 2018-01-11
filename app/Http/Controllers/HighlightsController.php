<?php

namespace App\Http\Controllers;

use App\Submission;
use App\Highlight;
use Carbon\Carbon;
use Illuminate\Http\Request;

use App\Http\Requests;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class HighlightsController extends Controller
{
    public function delete(Request $request) {
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'submission_id' => 'required|exists:highlights,submission_id'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $highlight = Highlight::where([['submission_id', '=', $request->submission_id], ['user_id', '=', $user->id]])->firstOrFail();

        $result = $highlight->delete();

        if ($result) {
            return response()->json(['success' => true], 200);
        } else {
            return response()->json(['error' => ['Failed to delete highlight.']], 500);
        }
    }

    public function store(Request $request) {
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'submission_id' => 'required|exists:submissions,id'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $submission = Submission::find($request->submission_id);

        if ($submission->user_id != $user->id) {
            return response()->json(['error' => ['You can only highlight your own submissions.']], 401);
        }

        $date = Carbon::parse($submission->created_at);
        $time_period = $date->year . '-' . $date->month . '-01 00:00:00';

        $existing_highlight = Highlight::where('time_period', '=', $time_period)->first();

        if ($existing_highlight) {
            $existing_highlight->submission_id = $submission->id;
            $existing_highlight->time_period = $time_period;
            $existing_highlight->save();
            $existing_highlight->submission;
            return $existing_highlight;
        } else {
            $highlight = new Highlight();
            $highlight->user_id = $user->id;
            $highlight->submission_id = $submission->id;
            $highlight->time_period = $time_period;
            $highlight->save();
            $highlight->submission;
            return $highlight;
        }
    }
}
