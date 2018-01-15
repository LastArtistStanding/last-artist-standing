<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    // * * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1

    /**
     * The Artisan commands provided by your application.
     *
     * @var array
     */
    protected $commands = [
        \App\Console\Commands\Inspire::class
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->call('\App\Http\Controllers\StreakController@end')->daily();
        $schedule->call('\App\Http\Controllers\CritiquesController@end')->daily();
        $schedule->call('\App\Http\Controllers\ChallengesController@end')->daily();
    }
}
