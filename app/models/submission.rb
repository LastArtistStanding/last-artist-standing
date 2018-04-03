class Submission < ApplicationRecord
    mount_uploader :drawing, ImageUploader

    belongs_to :user
    has_many :challenge_entries
    has_many :challenges, through: :challenge_entries
    validates :user_id, presence: true
    validates :drawing, presence: true
    #validates :thumbnail, presence: true
    validates :nsfw_level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
    validate :image_size_validation
 
    private
      def image_size_validation
        errors[:drawing] << "should be less than 2.5 MB" if drawing.size > 2.5 .megabytes
      end
end
