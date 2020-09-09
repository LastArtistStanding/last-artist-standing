# frozen_string_literal: true

threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

# Windows sucks and doesn't like workers
if RUBY_PLATFORM != 'x64-mingw32'
  workers Integer(ENV['WEB_CONCURRENCY'] || 2)
  preload_app!

  on_worker_boot do
    # Worker specific setup for Rails 4.1+
    # See: https://devcenter.heroku.com/articles/
    # deploying-rails-applications-with-the-puma-web-server#on-worker-boot
    ActiveRecord::Base.establish_connection
  end
end

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

# Allow serving HTTPS in the development environment so that we can test cross-site auth.
# Commenting out because it inexplicably breaks production!
# Uncomment it out yourself if you need to use it.
# if Rails.env.development? && ENV['DEVELOPMENT_TLS'].present?
#  cert_path = Rails.root.join('private')
#  ssl_bind '0.0.0.0', 3001, {
#    key: cert_path.join('key.pem').to_s,
#    cert: cert_path.join('cert.pem').to_s,
#    verify_mode: 'none'
#  }
# end
