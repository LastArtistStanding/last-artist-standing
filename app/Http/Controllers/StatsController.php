<?php

namespace App\Http\Controllers;

use App\ChallengeEntry;
use App\Critique;
use App\CritiqueReply;
use App\User;
use App\Submission;
use App\Streak;
use Exception;
use Illuminate\Support\Facades\DB;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Redis;

class StatsController extends Controller
{
    public function index() {
        $most_submissions = Submission::select(DB::raw('user_id, count(*) as total'))
            ->groupBy('user_id')
            ->orderBy('total', 'DESC')
            ->with('user')
            ->limit(5)
            ->get();

        $best_streak = Streak::orderBy('best', 'DESC')
            ->with('user')
            ->get();

        $most_crit_replies = CritiqueReply::select(DB::raw('user_id, count(*) as total'))
            ->groupBy('user_id')
            ->where('anonymous', '=', '0')
            ->orderBy('total', 'DESC')
            ->with('user')
            ->get();

        $most_challenge_entries = ChallengeEntry::select(DB::raw('user_id, count(*) as total'))
            ->groupBy('user_id')
            ->orderBy('total', 'DESC')
            ->with('user')
            ->get();

        $total_activity = [];
        foreach($best_streak as $streak) {
            if (!isset($total_activity[$streak->user->id])) {
                $total_activity[$streak->user->id] = [
                    'total' => 0,
                    'username' => $streak->user->username,
                    'user_id' => $streak->user->id
                ];
            }
            $total_activity[$streak->user->id]['total'] += $streak->best;
        }

        foreach($most_crit_replies as $reply) {
            if (!isset($total_activity[$reply->user->id])) {
                $total_activity[$reply->user->id] = [
                    'total' => 0,
                    'username' => $reply->user->username,
                    'user_id' => $reply->user->id
                ];
            }
            $total_activity[$reply->user->id]['total'] += $reply->total;
        }

        foreach($most_challenge_entries as $entry) {
            if (!isset($total_activity[$entry->user->id])) {
                $total_activity[$entry->user->id] = [
                    'total' => 0,
                    'username' => $entry->user->username,
                    'user_id' => $entry->user->id
                ];
            }
            $total_activity[$entry->user->id]['total'] += $entry->total;
        }

        usort($total_activity, function($a, $b) {
            return $b['total'] > $a['total'];
        });

        $active_critiques = Critique::where('status', '=', 'active')->count();
        $critique_replies = CritiqueReply::whereRaw('DATE(created_at) = UTC_DATE()')->count();

        return response()->json([
            'most_submissions' => $most_submissions,
            'best_streak' => $best_streak->splice(0, 5),
            'most_crit_replies' => $most_crit_replies->splice(0, 5),
            'most_challenge_entries' => $most_challenge_entries->splice(0, 5),
            'total_activity' => array_splice($total_activity, 0, 5, true)
        ], 200);
    }

    public function upRespect() {
        $count = Redis::get('stats:respect');
        $count++;
        Redis::set('stats:respect', $count);

        return response()->json(['respect' => $count]);
    }

    public function dashboard() {

        $submissions = Submission::whereRaw('DATE(created_at) = UTC_DATE()')->count();

        try {
            $user = JWTAuth::parseToken()->authenticate();
            if ($user) {
                $submission = Submission::whereRaw('user_id ='. $user->id .' AND DATE(created_at) = UTC_DATE()')->first();
                if ($submission) {
                    $submitted_today = true;
                } else {
                    $submitted_today = false;
                }
            } else {
                $submitted_today = 'guest';
            }
        } catch(JWTException $e) {
            if($e instanceof TokenExpiredException) {
                throw $e; // Keep throwing so it can be refreshed
            } else {
                $submitted_today = 'guest';
            }
        }

        /////////////////////////////////

        $newUsersCount = User::whereRaw('DATE(created_at) = UTC_DATE()')->count();

        $user_visits = User::whereRaw('DATE(last_seen) = UTC_DATE()')->count();

        /////////////////////////////////

        $streaks_started = Streak::whereRaw('DATE(current_start) = UTC_DATE() AND current != 0')->count();

        $streaks_ended = DB::select(DB::raw("
            SELECT count(*) as sum 
            FROM `streaks` 
            WHERE DATE(last_end) = DATE_SUB(UTC_DATE(), INTERVAL 2 day)"
        ))[0]->sum;

        /////////////////////////////////

        $respect = 0;

        try {
            $count = Redis::get('stats:respect');
            if ($count) {
                $respect = $count;
            }
        } catch(Exception $e) {}

        /////////////////////////////////

        return response()->json([
            'new_users' => $newUsersCount,
            'submissions' => $submissions,
            'submitted_today' => $submitted_today,
            'user_visits' => $user_visits,
            'streaks_started' => $streaks_started,
            'streaks_ended' => $streaks_ended,
            'respect' => $respect
        ], 200);
    }

    public function streamers() {
        $online_streamers = array();

        $toCheck = array(
            "aimai", "ultrabondagefairy", "CraniumOverLord", "dotesq", "magicoreo", "nakedoats",
            "N4F", "VitaminNeko", "Choob", "susipari",
            "HighOnDopamine", "namefag", "artscrub", "SubCryo", "NoajT",
            "noveltybestentertainment", "Lampblak", "TheThingInAPot", "poonwagon", "lordslump",
            "CathLAS", "radianart", "andrae", "mooff"
        );

        $picarto_key = env('PICARTO_API_KEY');

        if ($picarto_key) {
            $url = "https://api.picarto.tv/online/all/" . $picarto_key;
            $json = json_decode(file_get_contents($url));

            foreach($json as $key => $user) {
                if (in_array($user->channel_name, $toCheck)) {
                    array_push($online_streamers, $user);
                }
            }
        }

        return $online_streamers;
    }
}
