<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ChallengeVote extends Model
{

    protected $fillable = ['voted_for'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function entry() {
        return $this->belongsTo(ChallengeEntry::class);
    }
}
