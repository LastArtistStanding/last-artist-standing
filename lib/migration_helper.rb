# frozen_string_literal: true

# Custom Methods to be used in migrations

module MigrationHelper
  # Updates the database, making sure not to duplicate existing records.
  def updateDatabase
    updateChallenges
    updateBadges
    updateBadgeMaps
  end

  def updateChallenges
    challengeData = YAML.load_file('db/data/challenges.yaml')
    challengeData.each do |_currentChallenge, details|
      newChallenge = Challenge.find_or_create_by(name: details['name'])
      newChallenge.description = details['description']
      newChallenge.start_date = details['start_date']
      newChallenge.end_date = details['end_date']
      newChallenge.streak_based = details['streak_based']
      newChallenge.rejoinable = details['rejoinable']
      newChallenge.seasonal = details['seasonal']
      newChallenge.postfrequency = details['postfrequency']
      newChallenge.save
    end
  end

  def updateBadges
    badgeData = YAML.load_file('db/data/badges.yaml')
    badgeData.each do |_currentBadge, details|
      newBadge = Badge.find_or_create_by(name: details['name'])
      newBadge.direct_image = details['direct_image']
      newBadge.save
    end
  end

  def updateBadgeMaps
    badgeMapData = YAML.load_file('db/data/badgemaps.yaml')

    badgeMapData.each do |_currentBadgeMap, details|
      challenge = Challenge.find_by(name: details['challenge_name'])
      badge = Badge.find_by(name: details['badge_name'])
      newBadgeMap = BadgeMap.find_or_create_by(badge_id: badge.id, prestige: details['prestige'],
                                               challenge_id: challenge.id)
      newBadgeMap.description = details['description']
      newBadgeMap.required_score = details['required_score']
      newBadgeMap.save
    end
  end

  def updatePatchInfo
    patchNoteData = YAML.load_file('db/data/patchnotes.yaml')
    patchEntriesData = YAML.load_file('db/data/patchentries.yaml')

    patchNoteData.each do |_currentPatchNote, noteDetails|
      patchNote = PatchNote.find_by(patch: noteDetails['patch'])
      next if patchNote.present?

      patchNote = PatchNote.create({ before: noteDetails['before'], after: noteDetails['after'],
                                     patch: noteDetails['patch'] })
      if PatchNote.column_names.include?('title')
        patchNote.title = noteDetails['title']
        patchNote.save
      end
      patchEntriesData.each do |_currentPatchEntry, entryDetails|
        if patchNote.id == entryDetails['patchnote_id']
          PatchEntry.create({ patchnote_id: entryDetails['patchnote_id'],
                              body: entryDetails['body'], importance: entryDetails['importance'] })
        end
      end
    end
  end
end
