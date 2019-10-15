require 'rails_helper'

RSpec.describe Api::V1::Locations, type: :request do
  
  #Drivers require a organization to assosiate with
  let!(:organization) { FactoryBot.create(:organization) }
  #Created a token to by pass login but had to include
  #token_created_at in the last day so it would function
  let!(:driver) { FactoryBot.create(:driver, organization_id: organization.id,
     auth_token: "1234",token_created_at: Time.zone.now) }
  let(:driver2) { FactoryBot.create(:driver, organization_id: organization.id,
     auth_token: "5678",token_created_at: Time.zone.now) }
     #To test locations I needed to create some locations and also some relationships
  let!(:location){FactoryBot.create(:location)}
  let!(:location2){FactoryBot.create(:location, street: "1202 Dublin driver")}
  let!(:locationrelationship){LocationRelationship.create(driver_id: driver.id, location_id: location.id)}
  let!(:locationrelationship2){LocationRelationship.create(driver_id: driver.id, location_id: location2.id)}
  let!(:locationrelationship3){LocationRelationship.create(driver_id: driver2.id, location_id: location2.id)}



    #Created a Location based on the logged in user. Uses token previously created
  it 'will create a location related to logged in user' do

    post '/api/v1/locations', headers: {"ACCEPT" => "application/json",  "Token" => "1234"},
      params: {location:{street:"200 Front Street",
      city:"Burlington",
      state:"NC",
      zip: "27215"}}
      expect(response).to have_http_status(201)
      parsed_json = JSON.parse(response.body)
      expect(parsed_json['location']['street']).to eq('200 Front Street')
      expect(parsed_json['location']['city']).to eq("Burlington")
      expect(parsed_json['location']['state']).to eq('NC')
      expect(parsed_json['location']['zip']).to eq( "27215")
      expect(parsed_json['location']['location_relationships'][0]['driver_id']).to eq( driver.id)
  end
  
  # test should return a error message. Zip code must be numbers
  it 'should return a error code. Zip code must be number' do
    post '/api/v1/locations', headers: {"ACCEPT" => "application/json",  "Token" => "1234"},
      params: {location:{street:"500 Front Street",
      city:"Burlington",
      state:"NC",
      zip: "call me"}}
      
      expect(response).to have_http_status(400)
  end

  it 'will return locations of driver ' do

    get '/api/v1/locations', headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
      parsed_json = JSON.parse(response.body)
      locations = parsed_json['locations']
      thislocation = nil
      locations.each do |loc|
      if location['street'] == '1200 front st.'
       thislocation = location
        break
       end
      end
      expect(locations.length).to eq(2)
      expect(response).to have_http_status(200)
  end

  #Give the api a location id and get back information for it
  #Needs to verify user owns location
  it 'will return a location based on id passed ' do

    get "/api/v1/locations/#{location.id}", headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
    
      parsed_json = JSON.parse(response.body)
      expect(parsed_json['location']['street']).to eq('800 Park Offices Dr')
      expect(parsed_json['location']['city']).to eq('Durham')
      expect(parsed_json['location']['state']).to eq('NC')
      expect(parsed_json['location']['zip']).to eq( "27709")
      expect(response).to have_http_status(200)
  end
 
  it ' Updating a location with bad values should return an error message.' do
    put "/api/v1/locations/#{location.id}", headers: {"ACCEPT" => "application/json",  "Token" => "1234"},
      params: {location:{street:"2210 Front Street",
      city:"Burlington",
      state:"NC",
      zip: "Rails rules!"}}

      expect(response).to have_http_status(400)
      #uncomment these to see the error messages
      # parsed_json = JSON.parse(response.body)
      # puts parsed_json
  end
  
     it 'returns a new address when a location is shared by two drivers but update by one driver' do
    put "/api/v1/locations/#{location2.id}", headers: {"ACCEPT" => "application/json",  "Token" => "5678" },
      params: {location:{street:"1052 Canell Street",
      city:"Durham",
      state:"NC",
      zip: "27225"}}
      expect(response).to have_http_status(200)
      #uncomment these to see the error messages
      # parsed_json = JSON.parse(response.body)
      # puts parsed_json
  end
  
  
   #Delete Record based on id
  it 'will delete a location based on id passed ' do

    delete "/api/v1/locations/#{location.id}", headers: {"ACCEPT" => "application/json",  "Token" => "1234"}
      expect(Location.count).to eq(1)
      expect(response).to have_http_status(200)
  end
  
  it 'will return a error code of 401 when location does not belong to a driver ' do
    delete "/api/v1/locations/#{location.id}", headers: {"ACCEPT" => "application/json",  "Token" => "5678"}
      expect(response).to have_http_status(401)
  end
  
  it 'will return a error of code 404 when location is nil ' do
    delete "/api/v1/locations/#{44444}", headers: {"ACCEPT" => "application/json",  "Token" => "5678"}
      expect(response).to have_http_status(404)
  end
  
end

