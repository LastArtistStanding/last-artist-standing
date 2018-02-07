class Submission < ApplicationRecord
    
    mount_uploader :drawing, ImageUploader
    
    validates_processing_of :drawing
    validate :image_size_validation
 
    private
      def image_size_validation
        errors[:drawing] << "should be less than 1.0 MB" if drawing.size > 1.0 .megabytes
      end
end
