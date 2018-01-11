<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class UserBadge extends Model
{
    public function user() {
        return $this->belongsTo(User::class);
    }

    public function badge() {
        return $this->belongsTo(Badge::class);
    }
}
