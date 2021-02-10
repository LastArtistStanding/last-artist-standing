# frozen_string_literal: true

# Adds next submission date and last submission date to participations
class AddNextSubmissionDateToParticipation < ActiveRecord::Migration[5.0]
  def change
    change_table :participations, { bulk: true } do |t|
      t.date :next_submission_date, :last_submission_date
    end
  end
end
