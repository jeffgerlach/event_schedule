class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :track_name
      t.integer :display_order

      t.timestamps null: false
    end
    add_index :tracks, :track_name
  end
end
