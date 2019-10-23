class AddNumCommentsToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :num_comments, :integer
  end
end
