#Custom Methods to be used in migrations

module MigrationHelper
    
    #Updates the database, making sure not to duplicate existing records.
    def updateDatabase
        updateChallenges
        updateBadges
        updateBadgeMaps
    end
    
    def updateChallenges
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
    end
    
    def updateBadges
        badgeData = YAML.load_file('db/data/badges.yaml')
        badgeData.each do |currentBadge,details|
            newBadge = Badge.find_or_create_by(name: details["name"])
            newBadge.direct_image = details["direct_image"]
            newBadge.save
        end
    end
    
    def updateBadgeMaps
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