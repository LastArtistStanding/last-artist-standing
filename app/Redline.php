<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Redline extends Model
{
    protected $fillable = ['imagePath', 'comment'];
    protected $hidden = ['thumbnailPath'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function submission() {
        return $this->belongsTo(Submission::class);
    }
}
