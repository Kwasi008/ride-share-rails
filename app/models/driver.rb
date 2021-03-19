# frozen_string_literal: true

class Driver < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, length: { is: 10 }, numericality: true
  validates :email, presence: true
  validate :password_complexity
  validate :image_type

  belongs_to :organization
  has_many :location_relationships
  has_many :rides
  has_many :ride_logs
  has_many :schedule_windows
  has_many :vehicles, dependent: :destroy
  has_many :locations, -> { distinct }, through: :location_relationships

  has_one_attached :image
  # validates :image, attached: true, content_type: 'image/png',
  #                                   dimension: { width: 200, height: 200 }
  # validates_attachment_content_type :image, content_type:  ["image/jpg", "image/jpeg", "image/png"]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, password_length: 8..128
  scope :active, -> { where(is_active: true) }
  scope :pending, -> { where(application_state: 'pending') }
  scope :accepted, -> { where(application_state: 'accepted') }
  scope :rejected, -> { where(application_state: 'rejected') }
  before_save :lets_cap, only: %i[new create]
  before_save :downcase_email

  def thumbnail
    image.variant(resize: '300x300>').processed
  end

  def image_type
    if image.attached? && !image.content_type.in?(['image/jpg', 'image/png'])
      errors.add(:image, 'needs to be JPEG or PNG')
    end
  end

  # Converts email to all lower-case.
  def downcase_email
    email.downcase!
  end

  def lets_cap
    self.first_name = first_name.capitalize
    self.last_name = last_name.capitalize
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def generate_auth_token
    token = SecureRandom.hex
    update_columns(auth_token: token, token_created_at: Time.zone.now)
    token
  end

  def invalidate_auth_token
    update_columns(auth_token: nil, token_created_at: nil)
  end

  def events(query_start_date, query_end_date)
    list = []
    schedule_windows.each do |window|
      list += window.events(query_start_date, query_end_date)
    end
    list.sort_by { |i| i[:start_time] }.reverse
  end

  def overlapping_events(query_start_date, query_end_date)
    list = []
    schedule_windows.each do |window|
      next unless window.id # hard to understand why this if is necessary

      # but if an ActiveRecord is newed up in the context
      # of a transaction, it is returned if you select
      # it on the same thread, even though it isn't yet in the database
      list += window.overlapping_events(query_start_date, query_end_date)
    end
    list.sort_by { |i| i[:start_time] }.reverse
  end

  def password_complexity
    if password.present? and not password.match(/^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,25}$/)
      errors.add :password, "must be at least 8 characters long and include 1 uppercase, 1 number, and 1 special character."
    end
  end

  def default_location
    default_location_relationship = self.location_relationships.find_by_default(true)
    if default_location_relationship
      Location.find(default_location_relationship.location_id)
    end
  end
end
