class AddSameDriverToRides < ActiveRecord::Migration[5.2]
  def change
    add_column :rides, :same_driver, :boolean, default: false
  end
end
