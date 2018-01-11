<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Challenge extends Model
{
    protected $fillable = ['title', 'duration', 'description', 'rules', 'contest'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function entries() {
        return $this->hasMany(ChallengeEntry::class);
    }
}
