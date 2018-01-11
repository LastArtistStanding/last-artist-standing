<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ChallengeEntry extends Model
{
    protected $fillable = ['submission_id', 'challenge_id'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function submission() {
        return $this->belongsTo(Submission::class);
    }

    public function challenge() {
        return $this->belongsTo(Challenge::class);
    }

    public function votes() {
        return $this->hasMany(ChallengeVote::class);
    }
}
