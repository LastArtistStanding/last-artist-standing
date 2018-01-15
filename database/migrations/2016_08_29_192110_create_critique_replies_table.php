<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateCritiqueRepliesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('critique_replies', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('critique_id')->unsigned()->index();
            $table->foreign('critique_id')->references('id')->on('critiques');
            $table->integer('user_id')->unsigned()->index();
            $table->foreign('user_id')->references('id')->on('users');
            $table->mediumText('text');
            $table->boolean('anonymous');
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
        Schema::drop('critique_replies');
    }
}
