# frozen_string_literal: true

class AddNextSubmissionDateToParticipation < ActiveRecord::Migration[5.0]
  def change
    add_column :participations, :next_submission_date, :Date
    add_column :participations, :last_submission_date, :Date
  end
end
