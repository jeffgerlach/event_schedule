class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.string :course_name
      t.string :track_name
      t.boolean :shared_with_all
      t.timestamps null: false
    end
    add_index :events, :course_name
    add_index :events, :track_name
  end
end
