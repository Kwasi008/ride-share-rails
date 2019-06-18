require 'rails_helper'

RSpec.describe Api::DriversController, type: :request do
    let!(:organization) { FactoryBot.create(:organization) }
    let!(:driver) { FactoryBot.create(:driver, organization_id: 1) }
    it 'driver login in' do
    post '/api/v1/login', headers: {"ACCEPT" => "application/json" }, params: { email: "v1@sample.com", password: "password" }
       
       expect(response).to have_http_status(201) 
        puts response.body
    end
    def setup 
        let!(:organization) { FactoryBot.create(:organization) } 
        let!(:driver) { FactoryBot.create(:driver, organization_id: 1) }
    end
end
