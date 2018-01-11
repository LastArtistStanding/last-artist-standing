<?php

namespace App;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

class Streak extends Model
{
    public function user() {
        return $this->belongsTo(User::class);
    }

    public function updateStreak(Submission $submission) {
        if ($this->updated_at->isToday() && $this->current != 0) {
            // Don't update streak if already updated today.
            return false;
        }

        if (!$this->updated_at->isYesterday()) {
            // Reset streak if submitting, and you didn't submit yesterday

            // Update best dates if current is your best
            if ($this->current == $this->best) {
                $this->best_start = $this->current_start;
                $this->best_end = $this->updated_at;
            }

            if (Carbon::now()->subDays(2)->diff(Carbon::parse($this->last_end))->days != 0) {
                $this->last_end = $this->updated_at;
            }

            $this->current = 1;
            $this->current_start = $submission->created_at;
            return $this->save();
        }

        // Submitted yesterday and again today
        $this->current += 1; // Increase streak

        // Update best if current is your best streak
        if ($this->current == $this->best + 1) {
            $this->best = $this->current;
        }

        return $this->save();
    }

    public function endStreak() {
        if ($this->current == $this->best) {
            $this->best_start = $this->current_start;
            $this->best_end = $this->updated_at;
        }

        $this->last_end = $this->updated_at;
        $this->current_start = NULL;
        $this->current = 0;
        return $this->save();
    }

    public function store(Submission $submission) {
        $this->user_id = $submission->user_id;
        $this->current = 1;
        $this->current_start = $submission->created_at;
        $this->best = 1;
        $this->best_start = $submission->created_at;
        return $this->save();
    }
}
