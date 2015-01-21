class AddCreatorIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :creator_id, :string
    add_column :games, :participant_id, :string
     add_index :games, :creator_id
     add_index :games, :participant_id
  end
end
