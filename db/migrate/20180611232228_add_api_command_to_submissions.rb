class AddApiCommandToSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :api_command, :string
  end
end
