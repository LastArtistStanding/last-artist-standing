# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( jquery-3.2.1.js )
Rails.application.config.assets.precompile += %w( jquery-ui-1.12.1.custom.min.js )
Rails.application.config.assets.precompile += %w( popper.js )
Rails.application.config.assets.precompile += %w( bootstrap.min.js )
Rails.application.config.assets.precompile += %w( bootstrap-switch.min.js )
Rails.application.config.assets.precompile += %w( nouislider.js )
Rails.application.config.assets.precompile += %w( moment.min.js )
Rails.application.config.assets.precompile += %w( bootstrap-datetimepicker.min.js )
Rails.application.config.assets.precompile += %w( paper-kit.js )