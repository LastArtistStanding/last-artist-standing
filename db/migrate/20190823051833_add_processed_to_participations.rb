class AddProcessedToParticipations < ActiveRecord::Migration[5.0]
  def change
    add_column :participations, :processed, :date
    
    all_active = Participation.where('active = true')
    all_active.each do |p|
      p.processed = Date.today - 1.day
      p.save
    end
  end
end
