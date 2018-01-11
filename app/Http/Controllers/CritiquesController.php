<?php

namespace App\Http\Controllers;

use App\Critique;
use App\CritiqueReply;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class CritiquesController extends Controller
{
    public function index() {
        $critiques = Critique::orderBy('created_at', 'desc')
            ->join('users', 'users.id', '=', 'user_id')
            ->select('critiques.*', 'users.username')
            ->get();

        return $critiques;
    }

    public function show($id) {
        $critique = Critique::where('id', '=', $id)->with(['user', 'critiqueReplies.user'])->firstOrFail();

        foreach($critique->critiqueReplies as $key => $reply) {
            $reply->text = preg_replace('/(&nbsp;(<br\s*\/?>\s*)|(<br\s*\/?>\s*))+/im', "<br /><br />\n", nl2br($reply->text));

            if ($reply->anonymous == 1) {
                $reply->user_id = 0;
                unset($critique->critiqueReplies[$key]->user);
            }
        }

        return $critique;
    }

    public function store() {

        $validator = Validator::make(request()->all(), [
            'description' => 'sometimes|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $user = Auth::user();

        if (Critique::whereRaw('user_id = ' . $user->id . ' AND status = "active"')->first()) {
            return response()->json(['error' => ['You already have an active critique.']], 401);
        }

        $critique = new Critique(request()->all());
        $critique->user_id = $user->id;
        $critique->status = 'active';
        $critique->save();

        $critique->username = $user->username;
        return $critique;
    }

    public function storeReply($id) {

        $validator = Validator::make(request()->all(), [
            'text' => 'required|string|max:10000',
            'anonymous' => 'required|boolean'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $user = Auth::user();

        $critique = Critique::find($id);

        if ($critique->status == 'inactive') {
            return response()->json(['error' => ['You can\'t reply to inactive critiques.']], 401);
        }

        if ($critique->user_id == $user->id) {
            return response()->json(['error' => ['You can\'t reply to your own critique.']], 401);
        }

        if (CritiqueReply::whereRaw('user_id = ' . $user->id . ' AND critique_id = ' . $id)->first()) {
            return response()->json(['error' => ['You have already replied to this critique.']], 401);
        }

        $reply = new CritiqueReply();
        $reply->text = request()->text;
        $reply->anonymous = request()->anonymous;
        $reply->user_id = $user->id;
        $reply->critique_id = $id;
        $reply->save();

        $reply->user = $user;
        return $reply;
    }

    public function myReplies() {
        $user = Auth::user();
        $replies = CritiqueReply::select('critique_replies.*', 'critiques.status')
            ->join('critiques', 'critique_id', '=', 'critiques.id')
            ->where(['status' => 'active', 'critiques.user_id' => $user->id])
            ->with('user')
            ->get();

        foreach($replies as $key => $reply) {
            // Include linebreaks and combine multiple linebreaks into two
            $reply->text = preg_replace('/(&nbsp;(<br\s*\/?>\s*)|(<br\s*\/?>\s*))+/im', "<br /><br />\n", nl2br($reply->text));

            if ($reply->anonymous == 1) {
                $reply->user_id = 0;
                unset($replies[$key]->user);
            }
        }

        return $replies;
    }

    public function end() {
        $critiques = Critique::whereRaw('DATE(created_at) = DATE_SUB(UTC_DATE(), INTERVAL 7 day)')->get();

        foreach ($critiques as $critique) {
            $critique->status = 'inactive';
            $critique->save();
        }
    }
}
