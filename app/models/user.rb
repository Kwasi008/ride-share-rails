class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, password_length: 8..128
  validate :password_complexity

  belongs_to :organization
  has_many :ride_logs

  def password_complexity
    if password.present? and not password.match(/^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,25}$/)
      errors.add :password, "must be at least 8 characters long and include 1 uppercase, 1 number, and 1 special character."
    end
  end
end
