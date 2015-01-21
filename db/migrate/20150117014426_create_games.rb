class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|s
      t.timestamps
    end
  end
end
