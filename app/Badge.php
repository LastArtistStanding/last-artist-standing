<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Badge extends Model
{
    public function userBadge() {
        return $this->hasMany(Badge::class);
    }
}
