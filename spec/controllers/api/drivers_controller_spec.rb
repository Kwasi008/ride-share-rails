require 'rails_helper'

RSpec.describe Api::DriversController, type: :request do
    let!(:organization) { FactoryBot.create(:organization) }
    let!(:driver) { FactoryBot.create(:driver, organization_id: Organization.first.id) }
    it 'driver login in' do
    post '/api/v1/login', headers: {"ACCEPT" => "application/json" }, params: { email: "v1@sample.com", password: "password" }
       
       expect(response).to have_http_status(201) 
        puts response.body
    end
        it 'enrolls a driver' do
        post '/api/v1/drivers', headers: {"ACCEPT" => 'application/json' }, params: {driver: { 
            email: 'sample@sample.com', password: 'password', first_name: "bob", last_name: "frank", organization_id: Organization.first.id,
            radius: 50, phone: "3361234567", is_active: true}}
    
        expect(response).to have_http_status(200)
        puts response.body
    end
end
