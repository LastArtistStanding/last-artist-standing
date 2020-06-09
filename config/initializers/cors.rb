# frozen_string_literal: true

if !Rails.env.test? && ENV['X_AUTH_HOST'].present?
  # Currently, in production and staging, `config.hosts` protection *is not enabled*,
  # so ironically, whitelisting the x-auth enables the protection which breaks the site.
  # FIXME: Enable `config.hosts`-based protection for production environments.
  Rails.application.config.hosts << ENV['X_AUTH_HOST'] unless Rails.env.production?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins { ENV['X_AUTH_HOST'] }

      # Cross-site authentication

      # In this case, 'credentials' refers exclusively to the `x_auth` cookie.
      # No other cookies (like the session cookie) will be sent due to their SameSite policy.

      resource '/x_site_auth/auto_login_available', methods: %i[get], credentials: true
      resource '/x_site_auth/sign', methods: %i[post], credentials: true

      # Collections

      # There's no technical reason that these have to be restricted to particular origins;
      # if someone ever wants to make an app using these, it should be fine to allow them as well.
      # There are also many more endpoints which could be safely exposed but are not
      # (thoe only ones exposed here are those used by the DAD forums).
      # However, in security, I believe by granting the absolute minimum access necessary,
      # so I'm not going to enable these for all origins by default.
      # Likewise, both HEAD and OPTIONS should be safe methods to enable if desired.

      resource '/challenges/*', methods: %i[get]
      resource '/comments/*', methods: %i[get]
      resource '/submissions/*', methods: %i[get]
      resource '/users/*', methods: %i[get]
    end
  end
end
