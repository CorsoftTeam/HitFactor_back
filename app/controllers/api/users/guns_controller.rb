module Api
  module Users
    class GunsController < ApplicationController
      include UsersHelper
      skip_before_action :verify_authenticity_token
      before_action :check_token, :set_user
      before_action :set_gun, only: [ :sound, :update_sound, :update, :delete, :show]

      def sound
        render json: { gun_sound: @gun.sound.attached? ? url_for(@gun.sound) : nil }
      end
  
      def update_sound
        @gun.update!(sound: params[:sound], neyro_type: nil)
        render json: { gun_sound: @gun.sound.attached? ? url_for(@gun.sound) : nil }
      end
  
      def show
        render json: @gun
      end
  
      def index
        render json: user.guns
      end
  
      def create
        user.guns.create(guns_params)
        render json: user.guns, status: 201
      end
  
      def update
        @gun.update(guns_params) if @gun
        render json: user.guns, status: 201
      end
  
      def delete
        @gun.delete if @gun
        render json: user.guns, status: 204
      end

      private

      def guns_params
        params.permit(:name, :gun_type, :caliber, :serial_number, :sound)
      end

      def set_gun
        @gun ||= user.guns.find_by_id(params[:id].to_i)
        render json: { error: "no gun with id #{params[:id]}" } unless @gun
      end
    end
  end
end