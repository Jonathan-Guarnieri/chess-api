class CreatePieces < ActiveRecord::Migration[8.0]
  def change
    create_table :pieces do |t|
      t.integer :piece_type

      t.timestamps
    end
  end
end
