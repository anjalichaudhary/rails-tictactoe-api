class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :user_id
      t.boolean :player_won
      t.integer :player_move_count
      t.json :game_data
      t.boolean :is_drawn
      t.datetime :completed_at
      t.timestamps
    end
  end
end
