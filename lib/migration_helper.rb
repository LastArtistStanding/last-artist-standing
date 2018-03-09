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
            Challenge.find_or_create_by(name: details["name"]) do |newChallenge|
                newChallenge.description = details["description"]
                newChallenge.start_date = details["start_date"]
                newChallenge.end_date = details["end_date"]
                newChallenge.streak_based = details["streak_based"]
                newChallenge.rejoinable = details["rejoinable"]
                newChallenge.seasonal = details["seasonal"]
                newChallenge.postfrequency = details["postfrequency"]
            end
        end
    end
    
    def updateBadges
        badgeData = YAML.load_file('db/data/badges.yaml')
        badgeData.each do |currentBadge,details|
            Badge.find_or_create_by(name: details["name"]) do |newBadge|
                newBadge.avatar = details["avatar"]
            end
        end
    end
    
    def updateBadgeMaps
        badgeMapData = YAML.load_file('db/data/badgemaps.yaml')
        badgeMapData.each do |currentBadgeMap,details|
            BadgeMap.find_or_create_by(badge_id: details["badge_id"], challenge_id: details["challenge_id"], required_score: details["required_score"]) do |newBadgeMap|
                newBadgeMap.prestige = details["prestige"]
                newBadgeMap.description = details["description"]
            end
        end
    end
end