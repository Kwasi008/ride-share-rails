# frozen_string_literal: true

module Api
  module V1
    class Drivers < Grape::API
      include Api::V1::Defaults

      helpers SessionHelpers



      # Method to Create a Driver using api calls
      desc 'Create a Driver'
      params do
        requires :driver, type: Hash do
          requires :email, type: String
          requires :password, type: String
          requires :first_name, type: String
          requires :last_name, type: String
          requires :phone, type: String
          requires :organization_id, type: Integer
          requires :is_active, type: Boolean
          requires :admin_sign_up, type: Boolean, default: "false"
          optional :radius, type: Integer
        end
      end
      post 'drivers' do
        driver = Driver.new
        driver.attributes = params[:driver]
        if driver.save
          status 201
          return driver
        # Return bad request error code and error
        else
          status 400
          return {error: driver.errors.full_messages.to_sentence}
        end
      end

      desc 'Return the current driver'
      params do
        # requires :id, type: String, desc: "ID of driver"
      end
      get 'drivers', root: :driver do
        driver = current_driver
        if driver.nil?
          status 401
          return {}
        else
          location_ids = LocationRelationship.where(driver_id: current_driver.id)
          locations = []
          location_ids.each do |id|
            loc = {
              id: id.location.id,
              street: id.location.street,
              city: id.location.city,
              state: id.location.state,
              zip: id.location.zip,
              latitude: id.location.latitude,
              longitude: id.location.longitude,
              notes: id.location.notes,
              default: id.default
            }
            locations << loc
          end
        end
        status 200
        return { "driver": driver, "locations": locations }
      end

      desc 'Update current driver'
      params do
        requires :driver, type: Hash do
          optional :email, type: String
          optional :password, type: String
          optional :first_name, type: String
          optional :last_name, type: String
          optional :phone, type: String
          optional :is_active, type: Boolean
          optional :radius, type: Integer
        end
      end
      put 'drivers' do
        driver = current_driver
        if driver.nil?
          status 401
          return {}
        else
          driver.attributes = params[:driver]
          if driver.save
            status 200
            return driver
          else
            status 400
            return { error: driver.errors.full_messages.to_sentence }
          end
        end
      end

      desc 'Delete current driver'
      params do
      end
      delete 'drivers' do
        driver = current_driver
        if driver.nil?
          status 401
          return {}
        else
          driver.destroy
          status 200
          return {}
        end
      end

      desc 'Driver reset there own password from the app'
      params do
        requires :driver, type: Hash do
          requires :old_password, type: String
          requires :new_password, type: String
          requires :password_confirmation, type: String
        end
      end

      post 'drivers/changes_password' do
        if !current_driver
          status 401
          return {}
        end
        old_password = params[:driver][:old_password]
        new_password = params[:driver][:new_password]
        password_confirmation = params[:driver][:password_confirmation]
        if current_driver.valid_password?(old_password)
            if new_password == password_confirmation
              current_driver.update_attributes(password: new_password, password_confirmation: password_confirmation)
              if current_driver.save
                status 201
                return {}
              else
              status 400
              return {error: current_driver.errors.full_messages.to_sentence}
              end
            else
              status 400
              {error: "The new password and password confirmation do not match."}
            end
        else
          status 400
          {error: "The entry for the current password is not correct."}
        end
      end

      desc "Forgotten password, send driver an email with a link to set password"
      params do
        requires :email, type: String, desc: "Driver email"
      end

      post 'drivers/password_reset' do
        @driver = Driver.find_by_email(params[:email])
        if @driver.nil?
          status 404
          return {}
        else
          @driver.send_reset_password_instructions
          status 201
          return {}
        end
      end

      desc 'Prompt a driver to change password on first login if admin_sign_up is true'
      params do
        requires :driver, type: Hash do
          requires :password, type: String
          requires :password_confirmation, type: String
        end
      end
      put 'drivers/password_change' do
        if !current_driver
          status 401
          return {}
        end
        password = params[:driver][:password]
        password_confirmation = params[:driver][:password_confirmation]
        if current_driver.admin_sign_up?
          if password == password_confirmation
            current_driver.update_attributes(password: password, password_confirmation: password_confirmation, admin_sign_up: false) # Toggle admin_sign_up to false state on password change
            if current_driver.save
              status 201
              return {}
            else
              status 400
              return { error: current_driver.errors.full_messages.to_sentence }
            end
          else
            status 400
            return { error: "Password confirmation doesn't match password" }
          end
        end
      end

      desc "Return driver's current default location"
      get 'drivers/default_location' do
        if !current_driver
          status 401
          return {}
        end
        if current_driver.location_relationships.find_by_default(true)
          status 200
          return current_driver.default_location
        else
          status 404
          return {}
        end
      end
    end
  end
end
