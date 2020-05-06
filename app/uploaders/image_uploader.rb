# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog
  process :resize_to_limit => [3000, 3000], if: :requires_resize?
  process :strip_exif

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if is_submission?("")
      "submissions/#{model.user.name}/#{mounted_as}/#{model.id}"
    elsif is_badge?("")
      "badges/#{model.id}/#{mounted_as}"
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
  version :thumb do
    process :remove_animation, if: :is_animated_gif?
    process :resize_to_fill => [400, 400]
  end

  version :avatar, from_version: :thumb do
    process :resize_to_fill => [100, 100]
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

  protected
  def remove_animation
    manipulate! { |image| image.collapse! }
  end

  protected
  def strip_exif
    if content_type == 'image/jpeg' || content_type == 'image/jpg'
      manipulate! do |img|
        img.strip
        img = yield(img) if block_given?
        img
      end
    end
  end

  protected
  def is_animated_gif?(file)
    animated = false
    if content_type == 'image/gif' && file
      examining_image = ::MiniMagick::Image.open(file.file)
      animated = true if examining_image.layers.count > 1
    end
    if model.class.name == "Submission"
      model.is_animated_gif = animated
    end
    animated
  end

  protected
  def requires_resize?(file)
    model.errors.add(:drawing, "penis")
    if file
      width, height = ::MiniMagick::Image.open(file.file)[:dimensions]
      return width * height > 9000000
    end
    return false
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def size_range
    0..10.megabytes
  end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
