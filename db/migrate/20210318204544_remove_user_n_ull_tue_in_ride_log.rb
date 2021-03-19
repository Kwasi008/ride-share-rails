class RemoveUserNUllTueInRideLog < ActiveRecord::Migration[5.2]
  def change
    change_column :ride_logs, :user_id, :bigint, null: true
  end
end
