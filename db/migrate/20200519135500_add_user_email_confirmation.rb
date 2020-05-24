# frozen_string_literal: true

class AddUserEmailConfirmation < ActiveRecord::Migration[6.0]
  def change
    # Whether the user *account* is verified, i.e. they have *ever* verified an email address.
    add_column :users, :verified, :boolean, null: false, default: false
    # Whether the user's *current* email address is verified.
    add_column :users, :email_verified, :boolean, null: false, default: false
    # The email address the verification code is for,
    # to ensure you can't send a verification code for one email address,
    # then change your email address to something else, and still use the same verification code.
    add_column :users, :email_pending_verification, :string
    add_column :users, :email_verification_digest, :string
    add_column :users, :email_verification_sent_at, :datetime

    # Existing users are automatically verified, although their email address itself hasn't been.
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE users SET verified = TRUE;
        SQL
      end
      dir.down do
        # The row will be deleted, so no value needs to be set.
      end
    end
  end
end
