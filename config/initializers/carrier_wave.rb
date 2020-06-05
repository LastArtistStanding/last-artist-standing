# frozen_string_literal: true

require 'carrierwave/orm/activerecord'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  # The file-based backend *must* be used in testing,
  # and the S3-based backend *must* be used in production.
  # In the development environment, S3 will be used if possible,
  # but if it's not configured, fall back to the file-based backend.
  s3_configured = ENV['AWS_S3_BUCKET'].present?
  config.storage = if Rails.env.test? || (Rails.env.development? && !s3_configured)
                     :file
                   else
                     :fog
                   end
  config.enable_processing = false if Rails.env.test?
end
