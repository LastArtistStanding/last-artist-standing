<?php

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BadgesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('badges')->insert([
            'name' => '50 Submissions', 'file_name' => 'placeholder.png',
            'description' => 'You\'ve only just begun!'
        ]);

        DB::table('badges')->insert([
            'name' => '100 Submissions', 'file_name' => 'placeholder.png',
            'description' => 'Starting to pile up - keep going!'
        ]);

        DB::table('badges')->insert([
            'name' => '250 Submissions', 'file_name' => 'placeholder.png',
            'description' => 'Quite a few drawings! There\'s no turning back for you now.'
        ]);

        DB::table('badges')->insert([
            'name' => '500 Submissions', 'file_name' => 'placeholder.png',
            'description' => 'A whole lot of effort - Maybe now is a good time to reminisce and assess your progress.'
        ]);

        DB::table('badges')->insert([
            'name' => 'Minimalist', 'file_name' => 'placeholder.png',
            'description' => 'Sometimes less is more..'
        ]);

        DB::table('badges')->insert([
            'name' => 'Double Down', 'file_name' => 'placeholder.png',
            'description' => 'Every day is simply too easy!'
        ]);

        DB::table('badges')->insert([
            'name' => 'Speedster', 'file_name' => 'placeholder.png',
            'description' => 'C\'mon, Step it up!'
        ]);

        DB::table('badges')->insert([
            'name' => 'Daredevil', 'file_name' => 'placeholder.png',
            'description' => 'Just in time.'
        ]);
    }
}
