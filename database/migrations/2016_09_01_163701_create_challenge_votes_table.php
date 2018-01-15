<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateChallengeVotesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('challenge_votes', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('user_id')->unsigned()->index();
            $table->foreign('user_id')->references('id')->on('users');
            $table->integer('challenge_id')->unsigned()->index();
            $table->foreign('challenge_id')->references('id')->on('challenges');
            $table->integer('voted_for')->unsigned();
            $table->foreign('voted_for')->references('id')->on('challenge_entries');
            $table->unique(array('user_id', 'challenge_id'));
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('challenge_votes');
    }
}
