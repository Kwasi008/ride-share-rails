module Api
  module V1
    class Locations < Grape::API
      include Api::V1::Defaults
      helpers SessionHelpers

      before do
        error!('Unauthorized', 401) unless require_login!
      end


      #Lets driver look up resources that do no belong to them
      desc "Return a location with a given ID"
      params do
        requires :id, type: String, desc: "ID of the location"
      end
      get "locations/:id", root: :location do
        location = Location.find(permitted_params[:id])
        if location != nil
          status 200
        else
          status 404
        end
        render location
      end


      #Returns all locations of the current driver
      desc "Return all locations for a given driver"
      params do
      end
      get "locations" do
        driver = current_driver
        location_ids = LocationRelationship.where(driver_id: driver.id).select("location_id")
        locations = Location.where(id: location_ids)
        if locations != nil 
          status 200
        else
          status 404
        end
        render locations
      end

      #Create a location for the current driver
      #Needs address information to create
      desc "Create a new location from a driver"
      params do
        requires :location, type: Hash do
          requires :street , type:String
          requires :city, type:String
          requires :state, type: String
          requires :zip, type: String
        end
      end
      post "locations" do
        driver = current_driver
        location = Location.new
        location.attributes= (params[:location])
        if location.save
          LocationRelationship.create(location_id: location.id, driver_id: driver.id)
          status 201
          location
        else
          status 404
          location.errors.messages
        end
      end
      
 #Update a location for a driver
      desc "put a location from a driver"
        params do
          requires :id, type: Integer, desc: "ID of location"
          requires :location, type: Hash do
            optional :street , type:String
            optional :city, type:String
            optional :state, type: String
            optional :zip, type: String
          end
      end
  
      put "locations/:id" do
        #Find location to change
        old_location = Location.find(params[:id])
        if old_location == nil
          status 404 
          return ""
        end
        driver = current_driver
        if !driver_owns_location(driver, old_location) 
          status 401
          return ""
        end
        if LocationRelationship.where(location: permitted_params[:id]).count > 1
          new_location = Location.new(params[:location])
          save_success = new_location.save
          if !save_success
            status 400
            return new_location.errors.messages
          end
          location_relationship = LocationRelationship.where(location: permitted_params[:id], driver_id: driver.id).first
          location_relationship.location = new_location
        else
          #update old location
          update_success = old_location.update(params[:location])
          if update_success 
            old_location.reload
            render_value=old_location
            status 200
          else
            render_value = old_location.errors.messages
            status 400
          end
          render_value
        end
      end
      
      desc "Delete an association between a driver and a location"
      params do
        requires :id, type: String, desc: "ID of location"
      end
      delete 'locations/:id' do
        driver = current_driver
        old_location = Location.find(params[:id])
        if old_location.nil?
         status 404
         return ""
        end
        if driver_owns_location(driver, old_location)
          LocationRelationship.find_by(location_id: permitted_params[:id],
             driver_id: driver.id).destroy
          if LocationRelationship.where(location: permitted_params[:id]).count == 0
            old_location.destroy
            status 200
          end
        else
          status 401
        end
        return ""
      end
    end
  end
end

private 
     def driver_owns_location(driver, location)
     location_ids = LocationRelationship.where(driver_id: driver.id).pluck("location_id")
     location_ids.include?(location.id)
     end