namespace :dad_tasks do
  task :rollover_script => :environment do
    # The rollover script runs at 12:00 AM every night UTC.
    # Yesterday represents all of the submissions made the day prior,
    # giving context to what current_rollover refers to, if we're up to date.
    # Today represents what is the current day, if we're up to date.
    # Instead of using Date.today, we use these logged placeholders so that
    # we can rerun a failed or missed rollover.
    yesterday = SiteStatus.first.current_rollover
    today = yesterday + 1.day

    # Do not run the rollover script for a given day if it isn't over yet.
    return if yesterday >= Date.today
    
    # STEP 1: Check the challenge entries, identify users that aren't participating in DAD/Seasonal Challenge, and create those participations.
    # Get the users that have posted on the current rollover date
    user_ids = ChallengeEntry.where('created_at >= ? AND created_at < ? AND challenge_id = 1', yesterday, today).pluck(:user_id).uniq

    seasonal_challenge = Challenge.where(":yesterdays_date >= start_date AND :yesterdays_date < end_date AND seasonal = true", {yesterdays_date: yesterday}).first
    
    # For each user, check if they have an active DAD or seasonal participation. If not, create it.
    user_ids.each do |uid|
      dad_part = Participation.find_by(user_id: uid, challenge_id: 1, active: true)
      Participation.create({
        user_id: uid, 
        challenge_id: 1,
        active: true, 
        eliminated: false, 
        score: 0, 
        start_date: yesterday,
        last_submission_date: yesterday,
        next_submission_date: today,
        processed: yesterday - 1.day # so that this participation gets processed
      }) if dad_part.blank?

      season_part = Participation.find_by(user_id: uid, challenge_id: seasonal_challenge.id, active: true)
      Participation.create({
        user_id: uid,
        challenge_id: seasonal_challenge.id,
        active: true,
        eliminated: false,
        score: 0,
        start_date: yesterday,
        last_submission_date: yesterday,
        next_submission_date: today,
        processed: yesterday - 1.day
      }) if season_part.blank?
    end
    
    
    # STEP 2, process all DAD particicpations if they haven't been updated to this date yet (due to the script not running/crashing).
    dad_participations = Participation.where("active = true AND challenge_id = 1 AND processed = ?", yesterday - 1.day)
    dad_participations.each do |p|
      last_date = p.last_submission_date
      next_date = p.next_submission_date
      p_user = p.user

      dad_entries = ChallengeEntry.where("challenge_id = 1 AND user_id = #{p.user_id} AND created_at >= ? AND created_at < ? AND created_at < ?", last_date, next_date, today)
      
      if today == next_date && dad_entries.count == 0
        p.active = false
        p.eliminated = true
        p.end_date = yesterday
        p_user.update_attribute(:current_streak, 0)
      else
        if dad_entries.count > 0 && !p.submitted
          p.score += 1
          p.submitted = true
          p_user.update_attribute(:current_streak, p.score)
          if p.score > p_user.longest_streak
            p_user.update_attribute(:longest_streak, p.score)
          end
          
          dad_badge_map = BadgeMap.where("required_score <= #{p.score} AND challenge_id = 1").order("required_score DESC").first
          if !dad_badge_map.blank?
            previous_award = Award.find_by({user_id: p_user.id, badge_id: dad_badge_map.badge_id})
            if previous_award.blank?
              Award.create({
                user_id: p_user.id, 
                badge_id: dad_badge_map.badge_id, 
                date_received: today, 
                prestige: dad_badge_map.prestige
              })
            elsif previous_award.prestige < dad_badge_map.prestige
              previous_award.prestige = dad_badge_map.prestige
              previous_award.date_received = today
              previous_award.save
            end
          end
        end
        
        if !p_user.new_frequency.blank?
          # If the new frequency is easier, reset the streak
          if !p_user.dad_frequency.blank? && p_user.dad_frequency < p_user.new_frequency
            p.score = (p.score / 2.0).ceil
            p_user.update_attribute(:current_streak, p.score)
          end
          p_user.update_attribute(:dad_frequency, p_user.new_frequency)
          p.next_submission_date = p.last_submission_date + p_user.dad_frequency
          p.next_submission_date = today if p.next_submission_date < today
          p_user.update_attribute(:new_frequency, nil)
        end
        
        # Set the next_submission_date if yesterday is that date, advance by the specified postfrequency
        if today == next_date
          p.last_submission_date = next_date
          # Handle DAD's custom postfrequency
          p.next_submission_date = next_date + p_user.dad_frequency.days
          p.submitted = false
        end
      end
      
      p.processed = yesterday
      
      p.save
    end
    
    # STEP 3, process all other participations.
    all_participations = Participation.where("active = true AND challenge_id != 1 AND processed = ?", yesterday - 1.day)
    
    all_participations.each do |p|
      last_date = p.last_submission_date
      next_date = p.next_submission_date
      p_user = p.user
      challenge = p.challenge
      score_changed = false
      
      entries = ChallengeEntry.where("challenge_id = #{challenge.id} AND user_id = #{p.user_id} AND created_at >= ? AND created_at < ? AND created_at < ?", last_date, next_date, today)
      
      if today == next_date && entries.count == 0 && challenge.streak_based
        p.active = false
        p.eliminated = true
        p.end_date = yesterday
      else
        if entries.count > 0
          if challenge.postfrequency == 0
            score_changed = !(p.score == entries.count)
            p.score = entries.count
          elsif !p.submitted
            p.score += 1
            p.submitted = true
            score_changed = true
          end
        end
        
        if score_changed
          badge_map = BadgeMap.where("required_score <= #{p.score} AND challenge_id = #{challenge.id}").order("required_score DESC").first
          if !badge_map.blank?
            previous_award = Award.find_by({user_id: p_user.id, badge_id: badge_map.badge_id})
            if previous_award.blank?
              Award.create({
                user_id: p_user.id, 
                badge_id: badge_map.badge_id, 
                date_received: today, 
                prestige: badge_map.prestige
              })
            elsif previous_award.prestige < badge_map.prestige
              previous_award.prestige = badge_map.prestige
              previous_award.date_received = today
              previous_award.save
            end
          end
        end
        
        # If today is the ending date, terminate the participation.
        if today >= challenge.end_date
          p.active = false
          p.end_date = today
          p.eliminated = false
        elsif challenge.postfrequency != 0 && today == next_date
          p.last_submission_date = next_date
          p.next_submission_date = p.last_submission_date + challenge.postfrequency.days
          p.submitted = false
        end
      end
      
      p.processed = yesterday
      
      p.save
    end
    
    # STEP 4 Initialize participations.
    starting_participations = Participation.where(active: nil, start_date: today)
    
    starting_participations.each do |s|
      challenge = s.challenge

      s.active = true
      s.score = 0
      s.eliminated = false
      s.processed = yesterday
      
      if challenge.postfrequency = 0
        s.last_submission_date = challenge.start_date
        s.next_submission_date = challenge.end_date
      else
        s.last_submission_date = challenge.start_date
        s.next_submission_date = challenge.start_date + challenge.postfrequency.days
      end
      
      notification_text = "#{challenge.name} has started. It's time to start working on your submissions!"
      notification_text = "#{challenge.name} has started. Beware, this is an elimination-based challenge! Don't forget to submit." if challenge.streak_based
      
      # Participants should be notified
      Notification.create({
        body: notification_text,
        source_type: "Challenge",
        source_id: s.challenge_id,
        user_id: s.user_id,
        url: "/challenges/#{s.challenge_id}"
      })
      
      s.save
    end
    
    # STEP 5: Notify active people that a challenge has ended!
    ending_challenges = Challenge.where(end_date: today, seasonal: false)
    
    ending_challenges.each do |c|
      challenge_name = c.name
      challenge_id = c.id
      
      User.all.each do |u|
        # If the user has submitted within the last two weeks, send a notification of a starting challenge.
        next if Submission.find_by("created_at >= ? and user_id = ?", today - 14.day, u.id).nil?
        
        Notification.create({
          body: "#{challenge_name} has ended. Why not check out some of the entries?",
          source_type: "Challenge",
          source_id: challenge_id,
          user_id: u.id,
          url: "/challenges/#{challenge_id}/entries"
        })
      end
    end
    
    # STEP 6: Now that the daily job is complete, update.
    SiteStatus.first.update_attribute(:current_rollover, today)
  end
  
  desc "Initialize site status"
  task :init_site_status => :environment do
    SiteStatus.create(current_rollover: Date.today)
  end
  
  desc "Recalculate seasonal submissions."
  task :fix_seasonal, [:user_id, :challenge_id] => [:environment] do |t, args|
    user = User.find(args[:user_id])
    next if user.blank?
    challenge = Challenge.find(args[:challenge_id])
    next if challenge.blank? || !challenge.seasonal
    participation = Participation.find_by({user_id: user.id, challenge_id: challenge.id})
    next if participation.blank?
    
    score = 0
    
    s = challenge.start_date
    e = challenge.end_date
    e = Date.today if e > Date.today
    
    while s < e do
      entries = ChallengeEntry.where("challenge_id = #{challenge.id} AND user_id = #{user.id} AND created_at >= ? AND created_at < ?", s, s + 1.day)
      score += 1 if entries.count > 0
      s = s + 1.day
    end
    
    puts "Old score: #{participation.score}. New score: #{score}"
    
    participation.score = score
    participation.save
    
    badge_map = BadgeMap.where("required_score <= #{participation.score} AND challenge_id = #{challenge.id}").order("required_score DESC").first
    if !badge_map.blank?
      previous_award = Award.find_by({user_id: user.id, badge_id: badge_map.badge_id})
      if previous_award.blank?
        Award.create({
          user_id: user.id, 
          badge_id: badge_map.badge_id, 
          prestige: badge_map.prestige
        })
        puts "Award not found. Creating one."
      else
        puts "Changing prestige from #{previous_award.prestige} to #{badge_map.prestige}."
        previous_award.prestige = badge_map.prestige
        previous_award.save
      end
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
      
      badge.challenge_id = challenge.id
      badge.save
    end
  end
end
