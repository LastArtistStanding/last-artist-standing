<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Highlight extends Model
{
    public function user() {
        return $this->belongsTo(User::class);
    }

    public function submission() {
        return $this->belongsTo(Submission::class);
    }
}
