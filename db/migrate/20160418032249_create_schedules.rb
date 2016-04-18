class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :event_date
      t.timestamps null: false
    end
  end
end
