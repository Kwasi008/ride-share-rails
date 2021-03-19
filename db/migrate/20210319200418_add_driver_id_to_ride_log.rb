class AddDriverIdToRideLog < ActiveRecord::Migration[5.2]
  def change
    add_reference :ride_logs, :driver, foreign_key: true, null: true
    add_column :ride_logs, :created_at, :datetime, null: false
    add_column :ride_logs, :updated_at, :datetime, null: false
  end
end
