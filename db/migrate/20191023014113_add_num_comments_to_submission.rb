class AddNumCommentsToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :num_comments, :integer
    
    all_submissions = Submission.all
    all_submissions.each do |s|
      s.num_comments = s.comments.count
      s.save
    end
  end
end
