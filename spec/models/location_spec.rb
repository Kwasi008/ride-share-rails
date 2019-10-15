require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { create :location }
  it "has a valid factory" do
    FactoryBot.create(:location).should be_valid
  end

  describe 'Validations' do
    it { should validate_presence_of(:street) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should_not allow_value("zipCode").for(:zip) }
    it { should validate_length_of(:zip).is_equal_to(5) }
  end

  describe "Associations" do
    it { should have_many(:location_relationships) }
    it { should have_many(:schedule_windows) }
    it { should have_many(:drivers) }
  end

  describe 'Instance methods' do
    it "returns a location's full address as string" do
      expect(location.full_address).to eq("800 Park Offices Dr, Durham, NC 27709")
    end
  end

end
