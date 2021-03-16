require 'rails_helper'

RSpec.describe Api::V1::Rides, type: :request do
  #Drivers require a organization to assosiate with
  let!(:organization) {create(:organization)}
  #Created a token to by pass login but had to include
  #token_created_at in the last day so it would function
  # radius is set to miles by geocode
  let!(:driver) {create(:driver, organization_id: organization.id, auth_token: "1234",
                 radius: 5, is_active: true, token_created_at: Time.zone.now, background_check: true, application_state: "accepted")}
  let!(:driver2) {create(:driver, organization_id: organization.id,
                  auth_token: "4567",token_created_at: Time.zone.now) }
  #This driver is to test when driver is inactived
  let!(:driver3) {create(:driver, organization_id: organization.id,
                  auth_token: "1020", is_active: false, token_created_at: Time.zone.now)}

  let!(:driver4) {create(:driver, organization_id: organization.id, auth_token: "7897",
                                 radius: 5, is_active: true, token_created_at: Time.zone.now, background_check: true, application_state: "accepted")}

  let!(:rider) {create(:rider)}
  let!(:rider2) {create(:rider, first_name: "ben", email: 'sample@sample.com')}
  let!(:location) {create(:location)}

  # added a few more locations to test ride radius
  let!(:location1) {create(:location,  street:"5410 Page Rd", city: "Durham", state: "NC", zip: "27703")}
  let!(:location2) {create(:location,  street:"955 Airport Blvd", city: "Morrisville", state: "NC", zip: "27560")}
  let!(:location3) {create(:location,  street:"1001 Shiloh Glenn Dr", city: "Morrisville", state: "NC", zip: "27560")}
  let!(:location4) {create(:location,  street:"2301 Erwin Rd", city: "Durham", state: "NC", zip: "27710")}
  let!(:location5) {create(:location,  street:"113 N Salem St", city: "Apex", state: "NC", zip: "27502")}
  let!(:location6) {create(:location,  street:"945 Madison Ave", city: "New York", state: "NY", zip: "10021")}
  let!(:location7) {create(:location,  street:"201 W. Main st.", city: "Durham", state: "NC", zip: "27701")}
  # fake location to test when address doesnt exsits
  let!(:location8) {loc = FactoryBot.build(:location, street:"12345", city: "abndsjsk", state: "shkjslsjk", zip: "11111")
                    loc.save(validate: false)
                   }

  # the start location and end locations are helping with testing the radius of the rieds for the driver.
  let!(:ride) {create(:ride, rider_id: rider.id, organization_id: organization.id,
               start_location_id: location1.id, end_location_id: location2.id, status: "approved")}

  let!(:ride1) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "scheduled", pick_up_time: DateTime.now + 10.days,
                start_location_id: location2.id, end_location_id: location3.id)}

  let!(:ride2) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "picking-up",
                start_location_id: location3.id, end_location_id: location4.id)}

  let!(:ride3) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "scheduled",
                start_location_id: location4.id, end_location_id: location5.id)}

  let!(:ride4) {create(:ride, rider_id: rider2.id, organization_id: organization.id,
                driver_id: driver2.id, status: "scheduled",
                start_location_id: location2.id, end_location_id: location3.id)}

  let!(:ride5) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "scheduled",
                start_location_id: location5.id, end_location_id: location6.id)}

  let!(:ride6) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "scheduled",
                start_location_id: location6.id, end_location_id: location7.id)}

  # this ride test when ladditude is and longitude is nil
  let!(:ride7) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "scheduled",
                start_location_id: location7.id, end_location_id: location6.id)}

  let!(:ride8) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "dropping-off",
                start_location_id: location2.id, end_location_id: location3.id)}

  let!(:ride9) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver4.id, status: "scheduled",
                start_location_id: location2.id, end_location_id: location3.id)}

  let!(:ride10) {create(:ride, rider_id: rider.id, organization_id: organization.id,
                driver_id: driver.id, status: "returning-home",
                start_location_id: location2.id, end_location_id: location3.id)}

  #Accepts a ride for the current logged in user.
  #This added the driver id to the ride and changes the status to scheduled
  it 'will accept a ride for the driver' do
    post "/api/v1/rides/#{ride.id}/accept",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    parsed_json = JSON.parse(response.body)
    expect(response).to have_http_status(201)
    expect(parsed_json['ride']['driver_id']).to eq(driver.id)
    expect(parsed_json['ride']['status']).to eq("scheduled")
  end
  #Accepts a ride for the current logged user
  it 'will return a 404 error when ride does not belong to driver ' do
    post "/api/v1/rides/#{6565}/accept",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    expect(response).to have_http_status(404)

  end

  #Accepts a ride for the current logged user
  it 'will return a 401 error when ride does not belong to driver ' do
    post "/api/v1/rides/#{ride4.id}/accept",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    expect(response).to have_http_status(401)

  end

  #Changes status of ride to completed
  it 'will complete a ride for a driver' do
    post "/api/v1/rides/#{ride10.id}/complete",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    expect(response).to have_http_status(201)
    parsed_json = JSON.parse(response.body)
    expect(parsed_json['ride']['status']).to eq("completed")
  end

  #Changes status of ride to completed
  it 'will return a 401 error when ride does not belong to driver ' do
    post "/api/v1/rides/#{ride4.id}/complete",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    expect(response).to have_http_status(401)

  end

  it 'will put the ride to canceled status when cancelling a ride with scheduled status' do
    post "/api/v1/rides/#{ride1.id}/cancel",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"},
    params: { reason: "No Show"}
    parsed_json = JSON.parse(response.body)
    expect(parsed_json['ride']['status']).to eq("canceled")
  end

  it 'will return a 401 error when ride does not belong to driver ' do
    post "/api/v1/rides/#{ride4.id}/complete",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    expect(response).to have_http_status(401)

  end

  it 'will change status to picking up on a ride for a driver' do
    post "/api/v1/rides/#{ride9.id}/picking-up",  headers: {"ACCEPT" => "application/json",  "Token" => "7897"}
    parsed_json = JSON.parse(response.body)
    expect(parsed_json['ride']['status']).to eq("picking-up")
  end

  it 'Driver can only have one active ride.' do
    post "/api/v1/rides/#{ride3.id}/picking-up",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    parsed_json = JSON.parse(response.body)
    expect(parsed_json['error']).to eq("Sorry, there's a ride already in progress.")
  end


  it 'will change status to dropping off for a ride for a driver' do
    post "/api/v1/rides/#{ride2.id}/dropping-off",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    parsed_json = JSON.parse(response.body)
    expect(parsed_json['ride']['status']).to eq("dropping-off")
  end

  it 'will return a ride based off id ' do
    get "/api/v1/rides/#{ride1.id}",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    parsed_json = JSON.parse(response.body)
    # Checks to see if it equals what i set it to.
    expect(parsed_json['ride']['driver_id']).to eq(driver.id)
    expect(parsed_json['ride']['organization_id']).to eq(organization.id)
    expect(parsed_json['ride']['start_location']['id']).to eq(location2.id)
    expect(parsed_json['ride']['end_location']['id']).to eq(location3.id)
  end

  it 'will return a 401 error when ride does not belong to driver ' do
    get "/api/v1/rides/#{ride4.id}/",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    expect(response).to have_http_status(401)
  end

  context "rides list return different params " do
    #Returns all rides that have not been filled with a driver
    it 'will return all rides without drivers ' do
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{ status: ["approved"]}
      parsed_json = JSON.parse(response.body)
      #nil because no driver has accepted it yet
      expect(parsed_json['rides'][0]['driver_id']).to eq(nil)
      expect(response).to have_http_status(200)
    end

     #Returns all rides that h
    it 'will return a error when start time and end time are not nil' do
      Ride.destroy_all
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{
        start: Time.now,
        end: Time.now + 1.hour
      }
      expect(response).to have_http_status(404)
    end

    it 'will return a 404 error when organization is nil!' do
      Ride.destroy_all
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{
        organization_id: nil, status: ["approved", "scheduled", "picking-up", "dropping-off", "completed", "canceled"]
      }
      expect(response).to have_http_status(404)
    end

    # returns rides that only the driver has accepted
    it 'will return all rides that the  driver has accepted ' do
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{driver_specific: true}
      parsed_json = JSON.parse(response.body)
      #Driver should own all of these rides
      expect(parsed_json['rides'][0]['driver_id']).to eq(driver.id)
      expect(parsed_json['rides'][1]['driver_id']).to eq(driver.id)
      expect(parsed_json['rides'][2]['driver_id']).to eq(driver.id)
    end

    # returns rides that only the driver has accepted
    it 'will return a 404 error when ride does not belong to driver ' do
      Ride.destroy([ride1.id,ride2.id,ride3.id,ride5.id, ride6.id, ride7.id, ride8.id])
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{driver_specific: true}
      #Driver should own all of these rides
      expect(response).to have_http_status(404)
    end

    #Returns rides based on status matching scheduled and driver accepted
    it 'will return all rides with status scheduled' do
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{status: ["scheduled"]}
      parsed_json = JSON.parse(response.body)
      #should only have scheduled result, only should return one object
      expect(parsed_json['rides'][0]['status']).to eq("scheduled")
    end


    #Returns a 404 error when there is no status
    it 'will return a 404 error when status is nil' do
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{driver_specific: true, status: []}
      #should only have scheduled result, only should return one object
      expect(response).to have_http_status(404)
    end


  #Returns rides of driver with a start and end time and driver accepted, May want to loop through results
    it 'will return all rides start date' do
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{driver_specific: true, start: Date.today,
      end: Date.today + 15}
      parsed_json = JSON.parse(response.body)
      #Time formatting includes timezone information z and miliseconds
#      expect(parsed_json['rides'][0]['pick_up_time'].to_date).to eq(((Time.now.utc + 4.days).round(10).iso8601(3).to_date))
      expect(parsed_json['rides'][0]['pick_up_time'].to_date).to eq(ride.pick_up_time)
    end

     it 'will return a error 404 when ride does not belong to driver' do
       Ride.destroy([ride1.id,ride2.id,ride3.id,ride5.id, ride6.id, ride7.id, ride8.id])
      get "/api/v1/rides",  headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params:{driver_specific: true, start: Date.today,
      end: Date.today + 15}
      expect(response).to have_http_status(404)
    end
    # test for checking driver radius inconnection with rides
    it "Take a location id and returns back all in its radius" do
      get "/api/v1/rides", headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params: {
        location_id: location.id
      }
      parsed_json = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(parsed_json['rides'].count).to eq(3)
    end

    it "returns 404 when location does not exsit" do
      get "/api/v1/rides", headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params: {
        location_id: location6.id
        }
      expect(response).to have_http_status(404)
    end

    it "returns 404 when ride does not exsit" do
      get "/api/v1/rides/99999", headers: {"ACCEPT" => "application/json",  "Token" => "1234"} #ride_id 99999 doesn't exist
      expect(response).to have_http_status(404)
    end

    it "returns 404 when location latitude and longitude does not exsit" do
      get "/api/v1/locations/99999", headers: {"ACCEPT" => "application/json",  "Token" => "1234"} #location_id 99999 doesn't exist
      expect(response).to have_http_status(404)
    end

    it "returns 400 when location does not exsit " do
      Location.destroy_all
      get "/api/v1/rides", headers: {"ACCEPT" => "application/json",  "Token" => "1234"}, params: {
       location_id: 12344 }
       expect(response).to have_http_status(400)
    end

    # Test below shows when a driver is an inactived. Inactive drivers will not be able to get, complete or accept rides.

    it 'Will return a not authorized, when a inactived driver tries to accept rides' do
    get "/api/v1/rides/#{ride1.id}",  headers: {"ACCEPT" => "application/json",  "Token" => "1020"}
    expect(response).to have_http_status(401)
    end

    it "Will return a not authorized, when an inactived driver tries to recieve rides." do
      get "/api/v1/rides", headers: {"ACCEPT" => "application/json",  "Token" => "1020"}, params: {
        location_id: location.id
      }
      expect(response).to have_http_status(401)
    end

    it 'Will return a not authorized, when an inactived driver tries to complete a ride' do
    post "/api/v1/rides/#{ride1.id}/complete",  headers: {"ACCEPT" => "application/json",  "Token" => "1020"}
    expect(response).to have_http_status(401)
    end

    it 'Will return a not authorized, when an inactived driver accept a pick-up ride' do
     post "/api/v1/rides/#{ride1.id}/picking-up",  headers: {"ACCEPT" => "application/json",  "Token" => "1020"}
     expect(response).to have_http_status(401)
    end
  end
end
