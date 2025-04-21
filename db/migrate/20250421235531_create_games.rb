class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :white_player_id, null: false, foreign_key: { to_table: :users }
      t.references :black_player_id, null: false, foreign_key: { to_table: :users }
      t.string :fen
      t.references :winner_id, null: false, foreign_key: { to_table: :users }
      t.integer :win_type

      t.timestamps
    end
  end
end
