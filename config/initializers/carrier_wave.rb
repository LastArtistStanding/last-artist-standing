# frozen_string_literal: true

require 'carrierwave/orm/activerecord'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  if Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :fog
  end
end
