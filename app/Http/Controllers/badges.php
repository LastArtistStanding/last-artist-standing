<?php

namespace App\Http\Controllers;

use App\Submission;
use App\UserBadge;
use App\Badge;

trait badges {
    public function onSubmissionBadges($user, $submission, $streak, $image_pixels) {
        $submission_count = Submission::where('user_id', '=', $user->id)->count();

        $userBadges = UserBadge::where('user_id', $user->id)->get()->keyBy(function ($badge) {
            return $badge['badge_id'];
        });
        $badges = Badge::get()->keyBy(function ($badge) {
            return $badge['name'];
        });

        $this->submissionCounts($badges, $userBadges, $user, $submission_count);

        $this->streakCounts();

        $this->minimalisticSubmission($badges, $userBadges, $user, $image_pixels);

        $this->doubleDown($badges, $userBadges, $user, $submission_count, $streak->current);

        $this->timeTriggers($badges, $userBadges, $user, $submission);
    }

    /***************************************************************
     **** Time triggers ********************************************
     *  Submission time = 00:00:00 || 23:59:59 *********************
     **************************************************************/
    private function timeTriggers($badges, $userBadges, $user, $submission) {
        $time = $submission->created_at;
        $award_badge_id = 0;

        if ($time->hour == 0 && $time->minute == 0 && $time->second == 0) {
            $award_badge_id = $badges['Speedster']->id;
        } else if ($time->hour == 23 && $time->minute == 59 && $time->second == 59) {
            $award_badge_id = $badges['Daredevil']->id;
        }

        if ($award_badge_id == 0) { return false; }

        if (isset($userBadges[$award_badge_id])) { return false; }

        $user_badge = new UserBadge();
        $user_badge->user_id = $user->id;
        $user_badge->badge_id = $award_badge_id;
        return $user_badge->save();
    }

    /***************************************************************
     **** Submission counts ****************************************
     *  Submissions = 50 || 100 || 250 || 500 **********************
     **************************************************************/
    private function submissionCounts($badges, $userBadges, $user, $submission_count) {
        $award_badge_id = null;
        if ($submission_count == 50) {
            $award_badge_id = $badges['50 Submissions']->id;
        } else if ($submission_count == 100) {
            $award_badge_id = $badges['100 Submissions']->id;
        } else if ($submission_count == 250) {
            $award_badge_id = $badges['250 Submissions']->id;
        } else if ($submission_count == 500) {
            $award_badge_id = $badges['500 Submissions']->id;
        }

        if (!$award_badge_id) { return false; }

        if (isset($userBadges[$award_badge_id])) { return false; }

        $user_badge = new UserBadge();
        $user_badge->user_id = $user->id;
        $user_badge->badge_id = $award_badge_id;
        return $user_badge->save();
    }

    private function streakCounts() {
        // TODO
    }

    /***************************************************************
     **** Minimalist ***********************************************
     *  Submission aspect < 250x250 ********************************
     **************************************************************/
    private function minimalisticSubmission($badges, $userBadges, $user, $image_pixels) {
        $award_badge_id = $badges['Minimalist']->id;

        if (isset($userBadges[$award_badge_id])) { return false; }

        if ($image_pixels['height'] <= 250 && $image_pixels['width'] <= 250) {
            $user_badge = new UserBadge();
            $user_badge->user_id = $user->id;
            $user_badge->badge_id = $award_badge_id;
            return $user_badge->save();
        }

        return false;
    }

    /***************************************************************
     **** DOUBLE DOWN **********************************************
     *  Streak > 50 && submission count > streak * 2 **************
     ***************************************************************/
    private function doubleDown($badges, $userBadges, $user, $submission_count, $current_streak) {
        $award_badge_id = $badges['Double Down']->id;

        if (isset($userBadges[$award_badge_id])) { return false; }

        if ($current_streak >= 50 && $submission_count >= ($current_streak * 2)) {
            $user_badge = new UserBadge();
            $user_badge->user_id = $user->id;
            $user_badge->badge_id = $award_badge_id;
            return $user_badge->save();
        }

        return false;
    }

    // TODO - Someone had to say it.. - Submit an anonymous crit reply

    // TODO Helper - .. - Submit a critique and a redline

    // TODO Compulsive helper - You get help! And you get help! And you! And you! And you! - critique a lot

    // TODO On the rebound - Unaffected by superficial numbers on the internet - Submit the day after your streak ended

    // TODO I'm back - Everybody needs a vacation sometimes - submit after not submitting for over a week
}