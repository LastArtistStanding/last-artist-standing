class Submission < ApplicationRecord
    mount_uploader :drawing, ImageUploader

    belongs_to :user
    has_many :challenge_entries
    has_many :challenges, through: :challenge_entries
    has_many :comments, as: :source
    
    validates :user_id, presence: true
    validates :drawing, presence: true
    validates :title, length: { maximum: 100 }
    validates :description, length: { maximum: 2000 }
    #validates :thumbnail, presence: true
    validates :nsfw_level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
    validate :image_size_validation
 
    def is_animated_gif
      return false
      image = MiniMagick::Image.open(self.drawing.url)
      return false if image.type.downcase != "gif"
      return image.layers.count > 1
    end
 
    private
      def image_size_validation
        errors[:drawing] << "should be less than 10.0 MB" if drawing.size > 10.0 .megabytes
      end
end
