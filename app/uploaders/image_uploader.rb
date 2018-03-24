# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if is_submission?("")
      user = User.find(model.user_id)
      "submissions/#{user.name}/#{mounted_as}/#{model.id}"
    elsif is_badge?("")
      "badges/#{model.name}/#{mounted_as}"
    elsif is_user?("")
      "users/#{model.name}/#{mounted_as}"
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:

  # Create different versions of your uploaded files:
  version :thumb, :if => :is_submission? do
    process :resize_to_fill => [100, 100]
  end
  
  version :avatar, :if => :is_badge? do
    process :resize_to_fill => [50, 50]
  end
  
  version :avatar, :if => :is_user? do
    process :resize_to_fill => [50, 50]
  end
  
  protected
  def is_submission?(picture)
    model.class.to_s.underscore == "submission"
  end
    
  protected
  def is_badge?(picture)
    model.class.to_s.underscore == "badge"
  end
  
  protected
  def is_user?(picture)
    model.class.to_s.underscore == "user"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
