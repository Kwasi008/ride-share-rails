class RideLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :ride_logs do |t|
      t.string :action_type
      t.string :original_status
      t.string :new_status
      t.text :description
      t.timestamp
      t.references :user, null: false, foreign_key: true
      t.references :ride, null: false, foreign_key: true
    end
  end
end
