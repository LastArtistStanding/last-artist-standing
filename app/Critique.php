<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Critique extends Model
{
    protected $fillable = ['allow_anonymous', 'description'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function critiqueReplies() {
        return $this->hasMany(CritiqueReply::class);
    }
}
