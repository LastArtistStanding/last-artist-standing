<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class CritiqueReply extends Model
{
    public function critique() {
        return $this->belongsTo(Critique::class);
    }

    public function user() {
        return $this->belongsTo(User::class);
    }
}
