class RideLog < ApplicationRecord
  belongs_to :ride
  belongs_to :user, optional: true
  belongs_to :driver, optional: true
end
