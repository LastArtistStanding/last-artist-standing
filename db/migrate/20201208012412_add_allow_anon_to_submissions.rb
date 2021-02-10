# frozen_string_literal: true

class AddAllowAnonToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :allow_anon, :boolean, default: false
  end
end
