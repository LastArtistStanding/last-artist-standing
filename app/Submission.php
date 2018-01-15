<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Submission extends Model
{
    use SoftDeletes;

    protected $fillable = ['title', 'description', 'redline', 'nsfw'];
    protected $hidden = ['thumbnailPath'];
    protected $dates = ['deleted_at'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function challengeEntries() {
        return $this->hasMany(ChallengeEntry::class);
    }

    public function redlines() {
        return $this->hasMany(Redline::class);
    }

    public function highlight() {
        return $this->hasOne(Highlight::class);
    }
}
