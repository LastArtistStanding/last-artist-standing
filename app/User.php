<?php

namespace App;

use Carbon\Carbon;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    protected $fillable = [
        'username', 'email', 'password',
    ];

    protected $hidden = [
       'email', 'password', 'remember_token',
    ];

    public function submissions() {
        return $this->hasMany(Submission::class)->orderBy('created_at', 'DESC');
    }

    public function streak() {
        return $this->hasOne(Streak::class);
    }

    public function critiques() {
        return $this->hasMany(Critique::class);
    }

    public function follows() {
        return $this->hasMany(Follow::class);
    }

    public function badges() {
        return $this->hasMany(UserBadge::class);
    }

    public function redlines() {
        return $this->hasMany(Redline::class);
    }

    public function highlights() {
        return $this->hasMany(Highlight::class);
    }

    public function last_seen_now() {
        $last_seen = Carbon::parse($this->last_seen)->diffInMinutes();
        if ($last_seen >= 15 || !$last_seen) { // Update last seen max every 15 minutes
            $this->last_seen = Carbon::now();
            return $this->save();
        } else {
            return true;
        }
    }

    public function getMyRedlineInSubmission($submission_id) {
        $redline = Redline::where([['submission_id', '=', $submission_id], ['user_id', '=', $this->id]])->first();
        $redline->comment = preg_replace('/(&nbsp;(<br\s*\/?>\s*)|(<br\s*\/?>\s*))+/im', "<br /><br />\n", nl2br($redline->comment));
        return $redline;
    }
}
