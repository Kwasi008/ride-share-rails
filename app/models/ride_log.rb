class RideLog < ApplicationRecord
  belongs_to :ride
  belongs_to :user, optional: true
  # add belongs to driver optional equal true


end
