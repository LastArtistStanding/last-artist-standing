# frozen_string_literal: true

# Rake file to perform various dev tasks

namespace :dev_tasks do

  desc 'Fill database with test data'
  task create_test_data: :environment do
    logger = Logger.new($stdout)

    old_env = Rails.env
    Rails.env = 'development'

    logger.info 'Cleaning up old data'
    Rake::Task['dev_tasks:cleanup'].invoke

    logger.info 'Creating Admin'
    Rake::Task['dev_tasks:create_admin'].invoke

    logger.info 'Creating Users'
    Rake::Task['dev_tasks:generate_users'].invoke

    logger.info 'Creating Submissions'
    Rake::Task['dev_tasks:generate_submissions'].invoke

    logger.info 'Creating Boards'
    Rake::Task['dev_tasks:generate_boards'].invoke

    logger.info 'Creating Threads'
    Rake::Task['dev_tasks:generate_threads'].invoke

    logger.info 'Creating Challenges'
    Rake::Task['dev_tasks:generate_challenges'].invoke

    logger.info 'Creating Challenge Entries'
    Rake::Task['dev_tasks:generate_challenge_entries'].invoke

    logger.info 'Creating Badges'
    Rake::Task['dev_tasks:generate_badges'].invoke

    logger.info 'Creating BadgeMaps'
    Rake::Task['dev_tasks:generate_badge_maps'].invoke

    logger.info 'Creating Awards'
    Rake::Task['dev_tasks:generate_awards'].invoke

    logger.info 'Creating Participations'
    Rake::Task['dev_tasks:generate_participations'].invoke

    logger.info 'Creating Comments'
    Rake::Task['dev_tasks:generate_comments'].invoke

    logger.info 'Creating Houses'
    Rake::Task['dev_tasks:generate_houses'].invoke

    logger.info 'Creating House Participations'
    Rake::Task['dev_tasks:generate_house_participations'].invoke

    logger.info 'Creating Followers'
    Rake::Task['dev_tasks:generate_followers'].invoke

    logger.info 'Creating Moderator Applications'
    Rake::Task['dev_tasks:generate_moderator_applications'].invoke

    logger.info 'Creating Moderator Logs'
    Rake::Task['dev_tasks:generate_moderator_logs'].invoke

    logger.info 'Creating Notifications'
    Rake::Task['dev_tasks:generate_notifications'].invoke

    logger.info 'Creating Site Bans'
    Rake::Task['dev_tasks:generate_site_bans'].invoke

    logger.info 'Creating User Feedback'
    Rake::Task['dev_tasks:generate_user_feedbacks'].invoke

    logger.info 'Creating User Sessions'
    Rake::Task['dev_tasks:generate_user_sessions'].invoke

    Rails.env = old_env
  end

  task create_admin: :environment do
    User.create(
      name: 'admin',
      email: 'admin@dad.gallery',
      password: 'password',
      nsfw_level: 3,
      email_verified: true,
      verified: true,
      approved: true,
      is_moderator: true,
      is_developer: true,
      is_admin: true,
      highest_level: rand(0..25),
      current_streak: rand(0..100)
    )
  end

  task generate_users: :environment do
    100.times do |i|
      User.create(
        name: "Test#{i}",
        email: "test#{i}@test.com",
        password: 'password',
        nsfw_level: rand(1..3),
        email_verified: rand(0..1).zero?,
        verified: rand(0..1).zero?,
        approved: rand(0..1).zero?,
        is_moderator: rand(0..1).zero?,
        is_developer: rand(0..1).zero?,
        is_admin: false,
        highest_level: rand(0..25),
        current_streak: rand(0..100)
      )
    end
  end

  task generate_submissions: :environment do
    User.all.each do |u|
      rand(0..100).times do
        File.open("#{pwd}/app/assets/images/g#{rand(1..5)}.png", 'rb') do |f|
          Submission.create(
            user_id: u.id,
            created_at: Time.at(rand(3.months.ago.utc.to_i..Time.now.utc.to_i)).utc,
            time: rand(0..60 * 24),
            soft_deleted: rand(0..1).zero?,
            approved: rand(0..1).zero?,
            description: 'Test Description',
            commentable: rand(0..1).zero?,
            allow_anon: rand(0..1).zero?,
            nsfw_level: rand(1..3),
            title: 'Test Title',
            drawing: f,
            num_comments: rand(0..5),
            is_animated_gif: rand(0..1).zero?
          )
        end
      end
    end
  end

  task generate_boards: :environment do
    5.times do |i|
      Board.create(
        title: "Board ##{i}",
        alias: "board#{i}",
        permission_level: rand(1..3)
      )
    end
  end

  task generate_threads: :environment do
    50.times do |i|
      Discussion.create(
        user_id: User.all.sample.id,
        title: "Test Thread ##{i}",
        board_id: Board.all.sample.id,
        created_at: rand(1.week.ago.utc..Time.now.utc),
        nsfw_level: rand(1..3),
        locked: rand(0..1).zero?,
        pinned: rand(0..1).zero?,
        allow_anon: rand(0..1).zero?,
        anonymous: rand(0..1).zero?
      )
    end
  end

  task generate_challenges: :environment do
    30.times do |i|
      sd = rand(1.week.ago..1.week.from_now)
      Challenge.create(
        name: "Test Challenge ##{i}",
        description: "Test Challenge ##{i}",
        creator_id: User.all.sample.id,
        start_date: sd,
        end_date: sd + rand(2.weeks.from_now..3.weeks.from_now),
        streak_based: rand(0..1).zero?,
        rejoinable: rand(0..1).zero?,
        postfrequency: rand(1..7),
        seasonal: false,
        nsfw_level: rand(1..3),
        soft_deleted: rand(0..1).zero?
      )
    end
  end

  task generate_challenge_entries: :environment do
    100.times do
      si = Submission.all.sample
      ChallengeEntry.create(
        challenge_id: Challenge.where('seasonal = false and end_date is not null').sample.id,
        submission_id: si.id,
        user_id: si.user_id
      )
    end
  end

  task generate_badges: :environment do
    Challenge.where('seasonal = false and end_date is not null').each do |c|
      File.open("#{pwd}/app/assets/images/g#{rand(1..5)}.png", 'rb') do |f|
        Badge.create(
          name: c.name,
          avatar: f,
          nsfw_level: rand(1..3),
          challenge_id: c.id
        )
      end
    end
  end

  task generate_badge_maps: :environment do
    Challenge.where('seasonal = false and end_date is not null').each do |c, i|
      BadgeMap.create(
        badge_id: Badge.left_joins(:badge_maps).select('badges.id').where('badge_maps.id IS NULL').sample.id,
        challenge_id: c.id,
        required_score: rand(1..10),
        prestige: rand(1..5),
        description: "Test BadgeMap #{i}"
      )
    end
  end

  task generate_awards: :environment do
    500.times do
      bm = BadgeMap.joins(:challenge).where('challenges.seasonal = false and challenges.end_date is not null').sample
      Award.create(
        badge_id: bm.badge_id,
        user_id: User.all.sample.id,
        prestige: bm.prestige,
        date_received: rand(1.week.ago..1.week.from_now)
      )
    end
  end

  task generate_participations: :environment do
    Challenge.where('seasonal = false and end_date is not null').each do |c|
      20.times do
        Participation.create(
          challenge_id: c.id,
          active: rand(0..1).zero?,
          score: rand(0..10),
          eliminated: rand(0..1).zero?,
          start_date: rand(4.weeks.ago..3.weeks.ago),
          end_date: rand(1.week.ago..1.week.from_now),
          next_submission_date: rand(1.day.from_now..7.days.from_now),
          last_submission_date: rand(1.week.ago..Time.now.utc),
          submitted: rand(0..1).zero?,
          processed: rand(1.day.from_now..7.days.from_now),
          user_id: User.find_by_sql("select users.id from users left join (select * from participations where participations.challenge_id = #{c.id}) p on p.user_id = users.id where p.user_id is null").sample.id,
          created_at: Time.now.utc,
          updated_at: Time.now.utc
        )
      end
    end
  end

  task generate_comments: :environment do
    500.times do
      r = rand(0..2)
      if r.zero?
        st = 'Discussion'
        si = Discussion.all.sample.id
      elsif r == 1
        st = 'Challenge'
        si = Challenge.all.sample.id
      else
        si = Submission.all.sample.id
        st = 'Submission'
      end
      Comment.create(
        body: "# Markdown Cheat Sheet\n\nThanks for visiting [The Markdown Guide](https://www.markdownguide.org)!\n\nThis Markdown cheat sheet provides a quick overview of all the Markdown syntax elements. It can’t cover every edge case, so if you need more information about any of these elements, refer to the reference guides for [basic syntax](https://www.markdownguide.org/basic-syntax) and [extended syntax](https://www.markdownguide.org/extended-syntax).\n\n## Basic Syntax\n\nThese are the elements outlined in John Gruber’s original design document. All Markdown applications support these elements.\n\n### Heading\n\n# H1\n## H2\n### H3\n\n### Bold\n\n**bold text**\n\n### Italic\n\n*italicized text*\n\n### Blockquote\n\n> blockquote\n\n### Ordered List\n\n1. First item\n2. Second item\n3. Third item\n\n### Unordered List\n\n- First item\n- Second item\n- Third item\n\n### Code\n\n`code`\n\n### Horizontal Rule\n\n---\n\n### Link\n\n[Markdown Guide](https://www.markdownguide.org)\n\n### Image\n\n![alt text](https://www.markdownguide.org/assets/images/tux.png)",
        source_type: st,
        source_id: si,
        created_at: rand(1.week.ago.utc..Time.now.utc),
        user_id: User.all.sample.id,
        soft_deleted: rand(0..1).zero?,
        anonymous: rand(0..1).zero?
      )
    end
  end

  task generate_houses: :environment do
    12.times do |i|
      House.new(
        house_name: "House ##{i}",
        house_start: (i / 3).months.ago.at_beginning_of_month
      ).save(validate: false)
    end
  end

  task generate_house_participations: :environment do
    House.all.each do |h|
      rand(10..30).times do
        HouseParticipation.create(
          house_id: h.id,
          join_date: rand(h.house_start..h.house_start.to_date.end_of_month),
          score: rand(0..(60 * 24 * 30)),
          user_id: User.find_by_sql("select users.id from users left join (select * from house_participations where house_participations.id = #{h.id}) hp on hp.user_id = users.id where hp.user_id is null").sample.id
        )
      end
    end
  end

  task generate_followers: :environment do
    50.times do
      u = User.all.sample
      Follower.create(
        user_id: u.id,
        following_id: User.find_by_sql('select users.id from users left join followers on users.id = followers.user_id where followers.user_id is null and followers.following_id is null').sample.id
      )
    end
  end

  task generate_moderator_applications: :environment do
    20.times do
      ModeratorApplication.create(
        user_id: User.all.sample,
        time_zone: 'PST',
        active_hours: 'whenever',
        why_mod: 'whatever',
        past_experience: 'none',
        how_long: 'a million years',
        why_dad: 'because',
        anything_else: 'i like butterflies'
      )
    end
  end

  task generate_moderator_logs: :environment do
    20.times do
      ModeratorLog.create(
        user_id: User.where(is_moderator: true).sample.id,
        action: 'killed user',
        reason: 'to test my ability',
        target_type: 'User',
        target_id: User.where(is_moderator: false, is_admin: false).sample.id
      )
    end
  end

  task generate_notifications: :environment do
    if rand(0..1).zero?
      st = 'Comment'
      si = Comment.all.sample.id
    else
      st = 'Challenge'
      si = Challenge.all.sample.id
    end
    100.times do
      Notification.create(
        user_id: User.all.sample.id,
        source_type: st,
        source_id: si,
        body: 'This is a notification',
        read_at: rand(0..1).zero? ? nil : rand(2.weeks.ago.utc..Time.now.utc),
        url: '/'
      )
    end
  end

  task generate_site_bans: :environment do
    20.times do
      SiteBan.create(
        user_id: User.where(is_admin: false, is_moderator: false).sample.id,
        expiration: rand(2.weeks.ago.utc..2.weeks.from_now.utc),
        reason: 'because'
      )
    end
  end

  task generate_user_feedbacks: :environment do
    20.times do
      UserFeedback.create(
        title: 'test title',
        user_id: User.all.sample.id,
        body: 'i want cookies'
      )
    end
  end

  task generate_user_sessions: :environment do
    20.times do
      u = User.all.sample
      UserSession.create(
        user_id: u.id,
        ip_address: '127.0.0.1',
        name: u.name
      )
    end
  end

  task cleanup: :environment do
    User.all.each(&:destroy)
    Board.all.each(&:destroy)
    Challenge.where('seasonal = false and end_date is not null').each(&:destroy)
    House.all.each(&:destroy)
    UserSession.all.each(&:destroy)
    UserFeedback.all.each(&:destroy)
    ModeratorLog.all.each(&:destroy)
    rm_rf Dir['public/submissions/**']
    rm_rf Dir['public/badges/**']
  end
end
