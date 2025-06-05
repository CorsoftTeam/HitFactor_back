module Api
  class UsersController < ApplicationController
    include UsersHelper
    skip_before_action :verify_authenticity_token
    before_action :check_token, except: %i[ index create authorization ]
    before_action :set_user, only: %i[ get_user_image update_user_image last_shot find_gun_by_shoot]

    # GET /users or /users.json
    def index
      render json: { "error": "мы не показываем список всех пользователей"}
    end

    # GET /users/1 or /users/1.json
    def show
      @user = User.find_by_uuid(params[:uuid]) || { error: "Нет ни метода #{params[:uuid]}, ни пользователя с таким uuid"}
      render json: @user.except(:password)
    end

    def get_me
      @user = User.find_by_uuid(session[:uuid]) || { error: 'Пользователь не найден'}
      render json: @user.except(:password)
    end

    # POST /users or /users.json
    def create
      begin
        @user = User.create!(user_params.merge({ password: Digest::SHA256.hexdigest(params[:password]) }))
        @user.set_uuid
        @user.update(parameters: {}) if @user.parameters.nil?
        render json: generate_token, status: 201
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    # PATCH/PUT /users/1 or /users/1.json
    def update
      begin
        new_params = user_params
        new_params[:password] = Digest::SHA256.hexdigest(new_params[:password])
        user.update!(new_params)
        render json: user.except(:password)
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    # DELETE /users/1 or /users/1.json
    def destroy
      user.destroy!
    end

    def authorization
      @user = User.find_by(login: params[:login], password: Digest::SHA256.hexdigest(params[:password]))
      if @user
        render json: generate_token
      else
        render json: { "error": 'no_this_user' }, status: 401
      end
    end

    def get_user_image
      render json: { user_image: @user.image.attached? ? url_for(@user.image) : nil }
    end

    def update_user_image
      @user.update(image: params[:image])
      render json: { user_image: @user.image.attached? ? url_for(@user.image) : nil }
    end

    def last_shot
      @user.update(parameters: {}) if @user.parameters.nil?
      render json: @user.parameters['last_shot'].to_json, status: 200
    end

    def find_gun_by_shoot
      secret_gun = Gun.create!(user: @user, sound: params[:sound])
      
      if !secret_gun.sound.attached?
        secret_gun.delete
        render json: { error: 'no sound'}, status:  401
      else
        message ={
          user_id: @user.uuid,
          message_id: SecureRandom.uuid,
          data: @user.guns.select { |gun| gun.sound.attached? && !gun.name.nil? }.map do |gun|
            {
              id: gun.id,
              name: gun.name,
              sound_url: url_for(gun.sound),
              type: gun.neyro_type
            }
          end
        }
        message[:data] = message[:data] +[
                                            {
                                              id: secret_gun.id,
                                              name: nil,
                                              sound_url: url_for(secret_gun.sound),
                                              type: nil
                                            }
                                          ]
        
        publisher.send_message(message)
        render json: { message: message, status: 'successfully sended'}, status: 201
      end
    end

    private

    def publisher
      @publisher ||= RabbitPublisher.new
    end
  end
end