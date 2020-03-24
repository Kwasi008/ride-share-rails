class ChangeSameDriverColumnInRideTable < ActiveRecord::Migration[5.2]
  def change
    change_column :rides, :same_driver, :boolean, default: false
  end
end
