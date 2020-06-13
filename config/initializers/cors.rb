# frozen_string_literal: true

if !Rails.env.test? && ENV['X_AUTH_HOST'].present?
  # Currently, in production and staging, `config.hosts` protection *is not enabled*,
  # so ironically, whitelisting the x-auth enables the protection which breaks the site.
  # FIXME: Enable `config.hosts`-based protection for production environments.
  Rails.application.config.hosts << ENV['X_AUTH_HOST'] unless Rails.env.production?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins { ENV['X_AUTH_HOST'] }

      # In this case, 'credentials' refers exclusively to the `x_auth` cookie.
      # No other cookies (like the session cookie) will be sent due to their SameSite policy.
      resource '/x_site_auth/auto_login_available', methods: [:get], credentials: true
      resource '/x_site_auth/sign', methods: [:post], credentials: true
    end
  end
end
