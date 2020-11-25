# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process resize_to_limit: [3000, 3000], if: :requires_resize?
  process :strip_exif

  # Override the directory where uploaded files will be stored.
  def store_dir
    # FIXME: This sort of instanceof dispatch isn't good OO practice.
    if model.is_a? Submission
      "submissions/#{model.user.name}/#{mounted_as}/#{model.id}"
    elsif model.is_a? Badge
      "badges/#{model.id}/#{mounted_as}"
    elsif model.is_a? User
      "users/#{model.name}/#{mounted_as}"
    end
    # FIXME: There should probably be error handling for an undefined case.
  end

  # Alternative versions of uploaded files.

  version :thumb do
    process :remove_animation, if: :animated_gif?
    process resize_to_fill: [150, 150]
  end

  version :avatar, from_version: :thumb do
    process resize_to_fill: [50, 50]
  end

  protected

  def remove_animation
    manipulate!(&:collapse!)
  end

  def strip_exif
    # FIXME: Other file types like PNG can also contain unwanted metadata,
    #   which should probably also be stripped.
    # FIXME: Is the content type really not filtered at all to allow these redundant media types?
    #   And if not, is there a better way to determine file type?
    return unless content_type == 'image/jpeg' || content_type == 'image/jpg'

    manipulate! do |img|
      img.strip
      img = yield(img) if block_given?
      img
    end
  end

  def animated_gif?(file)
    animated = false
    # FIXME: This check should probably also apply to APNGs.
    if content_type == 'image/gif' && file
      examining_image = ::MiniMagick::Image.open(file.file)
      animated = true if examining_image.layers.count > 1
    end
    model.is_animated_gif = animated if model.is_a? Submission
    animated
  end

  def requires_resize?(file)
    # FIXME: Under what circumstances would 'file' be falsy?
    #   And is returning false the correct behavior in that circumstance?
    #   (This also applies to other predicates.)
    if file
      width, height = ::MiniMagick::Image.open(file.file)[:dimensions]
      # TODO: What is the purpose of this check or resizing?
      #   It does not prevent extreme dimensions (e.g. 1x9000000),
      #   and neither does it prevent large files (size_range does that).
      return width * height > 9_000_000
    end
    false
  end

  # Only these extensions are allowed to be uploaded.
  # TODO: Does CarrierWave actually verify the contents of the file?
  def extension_whitelist
    # APNGs are supported as PNGs.
    %w[apng jpg jpeg gif png]
  end

  def size_range
    0..10.megabytes
  end
end
