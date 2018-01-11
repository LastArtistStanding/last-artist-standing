<?php

use Illuminate\Support\Facades\Route;

//\DB::enableQueryLog();
//dd(\DB::getQueryLog());

Route::group(array('prefix' => 'api'), function() {
    Route::get('/', function () {
        return view('api');
    });

    Route::post('login', 'AuthController@authenticate');
    Route::post('register', 'AuthController@register');
    Route::get('refresh_token', 'AuthController@refresh');
    Route::get('logout', 'AuthController@logout');

    Route::get('submissions/offset/{offset?}', 'SubmissionsController@index');
    Route::get('submissions/newest', 'SubmissionsController@newest');
    Route::get('submissions/count', 'SubmissionsController@count');
    Route::get('submissions/{id}', 'SubmissionsController@show');
    Route::get('submissions/{id}/thumbnail', 'SubmissionsController@thumbnail');
    //Route::get('submissions/{id}/image', 'SubmissionsController@image');

    Route::get('streaks', 'StreakController@index');
    Route::get('streaks/end', 'StreakController@end');

    Route::get('critiques', 'CritiquesController@index');
    Route::get('critiques/end', 'CritiquesController@end');
    Route::get('critiques/{id}', 'CritiquesController@show');

    Route::get('stats', 'StatsController@index');
    Route::get('stats/dashboard', 'StatsController@dashboard');
    Route::get('stats/streamers', 'StatsController@streamers');

    Route::get('users', 'UserController@index');
    Route::get('users/{id}', 'UserController@show');
    Route::get('users/{id}/streak', 'UserController@streak');
    Route::get('users/{id}/submissions', 'UserController@submissions');
    Route::get('users/{id}/submissionsFromDate', 'UserController@getSubmissionsFromDate');

    Route::get('challenges', 'ChallengesController@index');
    Route::get('challenges/active', 'ChallengesController@active');
    Route::get('challenges/end', 'ChallengesController@end');
    Route::get('challenges/{id}', 'ChallengesController@show');
    Route::get('challenges/{id}/winner', 'ChallengesController@winner');

    Route::get('redlines/{id}/thumbnail', 'RedlinesController@thumbnail');

    Route::put('respect', 'StatsController@upRespect');

    Route::group(['middleware' => 'jwt.auth'], function () {

        Route::get('follows', 'UserController@getFollows');
        Route::put('follows', 'UserController@toggleFollow');

        Route::post('critiques', 'CritiquesController@store');
        Route::get('critiques/my/replies', 'CritiquesController@myReplies');
        Route::post('critiques/{id}', 'CritiquesController@storeReply');

        Route::post('submissions', 'SubmissionsController@store');
        Route::put('submissions/{id}', 'SubmissionsController@update');
        Route::delete('submissions/{id}', 'SubmissionsController@delete');

        Route::post('challenges', 'ChallengesController@store');
        Route::put('challenges/{id}', 'ChallengesController@update');
        Route::get('challenges/{id}/my_vote', 'ChallengesController@myVote');
        Route::post('challenges/{id}/vote', 'ChallengesController@vote');

        Route::post('submissions/{id}/redline', 'RedlinesController@store');
        Route::put('submissions/{id}/redline', 'RedlinesController@update');
        Route::get('feedback', 'RedlinesController@showMine');

        Route::post('highlight', 'HighlightsController@store');
        Route::post('unhighlight', 'HighlightsController@delete');

        Route::put('password', 'AuthController@updatePassword');
    });
});
