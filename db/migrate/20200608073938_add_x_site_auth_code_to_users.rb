# frozen_string_literal: true

# Add a cross-site authentication code to users.
# No expiry time is necessary because it behaves like a session token.
class AddXSiteAuthCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :x_site_auth_digest, :string
  end
end
