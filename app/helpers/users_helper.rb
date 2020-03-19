module UsersHelper
  def getUserThumb(user)
    if !user.avatar.nil?
      userThumb = user.avatar.thumb.url
    end
  
    if userThumb.blank?
      userThumb = "https://s3.us-east-2.amazonaws.com/do-art-daily-public/Default+User+Thumb.png"
    end
        
    userThumb
  end
    
  def getUserNsfwLevel(user)
    return 1 if user.blank? || user.nsfw_level.blank?
    
    user.nsfw_level
  end
    
  def getUserDADFrequency(user)
    if !user.new_frequency.blank?
      postfrequency = user.new_frequency
    elsif !user.dad_frequency.blank?
      postfrequency = user.dad_frequency
    else
      postfrequency = 0
    end
  end
    
  def getUserCurrentDADScore(user)
    participation = Participation.find_by({:user_id => user.id, :active => true, :challenge_id => 1})
    
    if participation.blank?
      "None"
    else
      participation.score
    end
  end
    
  def getUserScoreByChallenge(user, challenge)
    if user.blank? || challenge.blank?
      return 0
    end
    
    participation = Participation.find_by({:user_id => user.id, :challenge_id => challenge.id})
    
    if participation.blank?
      0
    else
      participation.score
    end
  end
    
  def getUserMaxLevel(user)
    if user.blank?
      return 0
    end
    
    award = Award.find_by({:user_id => user.id, :badge_id => 1})
    
    if award.blank?
      0
    else
      award.prestige
    end
  end
  
  def can_make_submission(user)
    return [false, "You must be logged in to post."] if user.blank?
    
    max_submissions = submission_limit(user)
    submissions_made_today = Submission.where("created_at >= ? AND created_at <= ? AND user_id = ?", Date.current.midnight, Date.current.end_of_day, user.id).count
    
    if max_submissions == -1
      [true, nil]
    elsif submissions_made_today < max_submissions
      [true, nil]
    else
      [false, "You have reached your daily submission limit (currently #{max_submissions})."]
    end
  end
  
  def submission_limit(user)
    max_dad_level = getUserMaxLevel(user)
    if max_dad_level <= 2
      2
    elsif max_dad_level <= 4
      4
    else
      -1
    end
  end
  
  def can_make_challenge(user)
    if getUserMaxLevel(user) >= 4
      active_challenges_made = Challenge.where("end_date > ? AND creator_id = ?", Date.current, user.id).count
      if active_challenges_made < 2
        [true, nil]
      else
        [false, "You can make at most two active or upcoming challenges before you create another."]
      end
    else
      [false, "You must have reached at least level 4 before you can make a challenge."]
    end
  end
end
