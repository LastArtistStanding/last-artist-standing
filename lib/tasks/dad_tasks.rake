namespace :dad_tasks do
    desc "Updates participations and scores."
    task :daily_challenge_check => :environment do
        # Fish in all active participations
        allParticipations = Participation.where(active: true)
        
        allParticipations.each do |p|
            # Get challenge entries made to the challenge between the last_submission_date and next_submission_date
            lastDate = p.last_submission_date
            nextDate = p.next_submission_date
            user = p.user
            challenge = p.challenge
            isDAD = p.challenge.id == 1
            scoreChanged = false
        
            challengeEntries = ChallengeEntry.where("challenge_id = :challengeId AND user_id = :userId AND created_at >= :last_date AND created_at < :next_date AND created_at < :current_date", {challengeId: challenge.id, userId: user.id, last_date: lastDate, next_date: nextDate, current_date: Date.today})
            
            # Eliminate anyone who failed to post in a streak_based challenge
            if Date.current == nextDate && challengeEntries.count == 0 && challenge.streak_based
                p.active = false
                p.eliminated = true
                p.end_date = Date.current - 1.day
                user.update_attribute(:dad_frequency, nil)
                user.update_attribute(:new_frequency, nil)
            else
                # Increment score
                if challengeEntries.count > 0
                    if challenge.postfrequency == 0
                        p.score = challengeEntries.count
                        scoreChanged = true
                    elsif !p.submitted
                        p.score += 1
                        p.submitted = true
                        scoreChanged = true
                    end
                end 
                
                if scoreChanged
                    # Check if the score has exceeded the user's previous record, replace it if so
                    if isDAD && p.score > user.longest_streak
                        user.update_attribute(:longest_streak, p.score)
                    end
                    
                    # Award and/or update badges
                    badgeToAward = BadgeMap.where("required_score <= :current_score AND challenge_id = :challengeId", {current_score: p.score, challengeId: challenge.id}).order("required_score DESC").first
                    if !badgeToAward.blank?
                        previousAward = Award.find_by(:user_id => user.id, :badge_id => badgeToAward.badge_id)
                        if previousAward.blank?
                            Award.create({:user_id => user.id, :badge_id => badgeToAward.badge_id, :date_received => Date.current, :prestige => badgeToAward.prestige})
                        elsif previousAward.prestige < badgeToAward.prestige
                            previousAward.prestige = badgeToAward.prestige
                            previousAward.date_received = Date.current
                            previousAward.save
                        end
                    end
                end 
                
                # If we've reached the last date of the challenge, deactivate it.
                if !challenge.end_date.blank? && Date.current >= challenge.end_date
                    p.active = false
                    p.end_date = Date.current
                    p.eliminated = false
                else
                    # First (DAD-only) check if the postfrequency of the user has been changed to a lower one
                    # Either way, update the new requested frequency
                    if isDAD
                        # If there wasn't a previous frequency, just populate it.
                        if user.dad_frequency.blank?
                            # Fixing a problem I made, haha.
                            if user.new_frequency.blank?
                                dateBasedFrequency = nextDate - lastDate
                                user.update_attribute(:dad_frequency, dateBasedFrequency)
                            else
                                user.update_attribute(:dad_frequency, user.new_frequency)
                            end
                        else
                            if !user.new_frequency.blank?
                                # If the new frequency is easier, reset the streak
                                if user.dad_frequency < user.new_frequency
                                    # The only way a frequency can be changed is through a submission, so you start with a score of 1.
                                    p.score = 1
                                end
                                user.update_attribute(:dad_frequency, user.new_frequency)
                            end
                        end
                    end
                    
                    # Set the next_submission_date if today is that date, advance by the specified postfrequency
                    if Date.current == nextDate
                        p.last_submission_date = nextDate
                        # Handle DAD's custom postfrequency
                        if challenge.postfrequency == -1
                            p.next_submission_date = p.last_submission_date + user.dad_frequency.days
                        # Note that custom postfrequencies don't change submission date periods
                        elsif challenge.postfrequency != 0
                            p.next_submission_date = p.last_submission_date + challenge.postfrequency.days
                        end
                        p.submitted = false
                    end
                    
                end
                
            end
            
            # Save changes to participation.
            p.save
            
        end
        
        # Initialize any participations if the start_date has been reached
        startingParticipations = Participation.where(active: nil, start_date: Date.current)
        
        startingParticipations.each do |s|
            
            challenge = s.challenge
            
            s.active = true
            s.score = 0
            s.eliminated = false
            
            # If the user can submit whenever, the submission period is the full duration of the challenge.
            if challenge.postfrequency == 0
                s.last_submission_date = challenge.start_date
                s.next_submission_date = challenge.end_date
            # Otherwise, the deadline is dictated by challenge postfrequency
            else
                s.last_submission_date = challenge.start_date
                s.next_submission_date = challenge.start_date + challenge.postfrequency.days
            end
            
            # Save changes to participation.
            s.save
            
        end
    end
    
    desc "Patch fix for orphaned participations."
    task :fix_inactive_participations => :environment do
        # Initialize any participations if the start_date has been reached
        startingParticipations = Participation.where(active: nil, start_date: Date.current)
        
        startingParticipations.each do |s|
            
            challenge = s.challenge
            
            s.active = true
            s.score = 0
            s.eliminated = false
            
            # If the user can submit whenever, the submission period is the full duration of the challenge.
            if challenge.postfrequency == 0
                s.last_submission_date = challenge.start_date
                s.next_submission_date = challenge.end_date
            # Otherwise, the deadline is dictated by challenge postfrequency
            else
                s.last_submission_date = challenge.start_date
                s.next_submission_date = challenge.start_date + challenge.postfrequency.days
            end
            
            # Save changes to participation.
            s.save
            
        end
    end
    
    desc "Update patch notes."
    task :update_patch_notes => :environment do
        patchNoteData = YAML.load_file('db/data/patchnotes.yaml')
        patchEntriesData = YAML.load_file('db/data/patchentries.yaml')
        
        patchNoteData.each do |currentPatchNote,noteDetails|
            patchNote = PatchNote.find_by(patch: noteDetails["patch"])
            if patchNote.blank?
                patchNote = PatchNote.create({ :before => noteDetails["before"], :after => noteDetails["after"], :patch => noteDetails["patch"] })
                if PatchNote.column_names.include?("title")
                    patchNote.title = noteDetails["title"]
                    patchNote.save
                end
                patchEntriesData.each do |currentPatchEntry,entryDetails|
                    if patchNote.id == entryDetails["patchnote_id"]
                        PatchEntry.create({ :patchnote_id => entryDetails["patchnote_id"], :body => entryDetails["body"], :importance => entryDetails["importance"] })
                    end
                end
            end
        end
    end
    
    desc "Update site challenges and badges."
    task :update_database => :environment do
        challengeData = YAML.load_file('db/data/challenges.yaml')
        challengeData.each do |currentChallenge,details|
            newChallenge = Challenge.find_or_create_by(name: details["name"])
            newChallenge.description = details["description"]
            newChallenge.start_date = details["start_date"]
            newChallenge.end_date = details["end_date"]
            newChallenge.streak_based = details["streak_based"]
            newChallenge.rejoinable = details["rejoinable"]
            newChallenge.seasonal = details["seasonal"]
            newChallenge.postfrequency = details["postfrequency"]
            newChallenge.save
        end
    
        badgeData = YAML.load_file('db/data/badges.yaml')
        badgeData.each do |currentBadge,details|
            newBadge = Badge.find_or_create_by(name: details["name"])
            newBadge.direct_image = details["direct_image"]
            newBadge.save
        end
    
        badgeMapData = YAML.load_file('db/data/badgemaps.yaml')
        
        badgeMapData.each do |currentBadgeMap,details|
            challenge = Challenge.find_by(name: details["challenge_name"])
            badge = Badge.find_by(name: details["badge_name"])
            newBadgeMap = BadgeMap.find_or_create_by(badge_id: badge.id, prestige: details["prestige"], challenge_id: challenge.id)
            newBadgeMap.description = details["description"]
            newBadgeMap.required_score = details["required_score"]
            newBadgeMap.save
        end
    end
end