<?php

namespace App\Http\Controllers;

use App\Streak;

class StreakController extends Controller
{
    public function index() {
        return Streak::with('user')->orderBy('current', 'DESC')->get();
    }

    public function end() {
        $streaks = Streak::whereRaw('DATE(updated_at) = DATE_SUB(UTC_DATE(), INTERVAL 2 day) AND current != 0')->get();

        foreach ($streaks as $key => $streak) {
            $streak->endStreak();
        }
    }
}