# frozen_string_literal: true

# Adds Password Digest to Users
class AddPasswordDigestToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :password_digest, :string
  end
end
