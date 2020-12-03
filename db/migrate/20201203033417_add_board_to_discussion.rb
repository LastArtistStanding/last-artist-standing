class AddBoardToDiscussion < ActiveRecord::Migration[6.0]
  def change
    add_reference :discussions, :board, foreign_key: true
  end
end
