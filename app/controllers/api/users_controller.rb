module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :check_token, except: %i[ index create authorization ]

    # GET /users or /users.json
    def index
      render json: { "error": "мы не показываем список всех пользователей"}
    end

    # GET /users/1 or /users/1.json
    def show
      @user = User.find_by_uuid(params[:id]) || { error: "Нет ни метода #{params[:id]}, ни пользователя с таким id"}
      render json: @user.except(:password)
    end

    def get_me
      @user = User.find_by_uuid(session[:id]) || { error: 'Пользователь не найден'}
      render json: @user.except(:password)
    end

    # POST /users or /users.json
    def create
      if valid_user_params?(user_params)
        @user = User.create!(user_params.merge({ password: Digest::SHA256.hexdigest(params[:password]) }))
        @user.set_uuid
        render json: generate_token, status: 201
      else
        render json: { "error": "Ошибка в параметрах пользователя" }, code: 401
      end
    end

    # PATCH/PUT /users/1 or /users/1.json
    def update
      set_user
      new_params = user_params
      new_params[:password] = Digest::SHA256.hexdigest(new_params[:password])
      @user.update!(new_params)
      render json: @user.except(:password)
    end

    # DELETE /users/1 or /users/1.json
    def destroy
      set_user
      @user.destroy!
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
        render json: { user_image: user.image.attached? ? url_for(user.image) : nil }
    end

    def update_user_image
      @user.update(image: params[:image])
      render json: { user_image: user.image.attached? ? url_for(user.image) : nil }
    end

    def get_gun_sound
      gun = user.guns.find_by_id(params[:gun_id])
      render json: { gun_sound: gun.sound.attached? ? url_for(gun.sound) : nil }
    end

    def update_gun_sound
      gun = user.guns.find_by_id(params[:gun_id])
      gun.update(sound: params[:sound])
      render json: { gun_sound: gun.sound.attached? ? url_for(gun.sound) : nil }
    end

    def gun
      render json: @user.guns.find_by_id(params[:gun_id])
    end

    def guns
      render json: { "error": "token error" }, status: 403
      render json: @user.guns
    end

    def create_gun
      user.guns.create(guns_params)
      render json: @user.guns, status: 201
    end

    def update_gun
      gun = user.guns.find_by_id(params[:gun_id])
      gun.update(guns_params) if gun
      render json: @user.guns, status: 201
    end

    def delete_gun
      gun = user.guns.find_by_id(params[:gun_id])
      gun.delete if gun
      render json: @user.guns, status: 204
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find_by_uuid(params[:id])
      end

      def user
        @user ||= User.find_by_uuid(params[:id])
      end 

      # Only allow a list of trusted parameters through.
      def user_params
        params.require(:user).permit(:name, :last_name, :login, :email, :phone_number, :password, :uuid, :parameters)
      end

      def generate_token
        session[:token_time] = Time.now
        session[:token] = SecureRandom.hex(32)
        session[:id] = @user.uuid
        {token: session[:token]}
      end

      def check_token
        time = Time.now - (session[:token_time]&.to_time || Time.at(0))
        render json: { 'error': 'token error' }, status: 403 unless (session[:token] == request.headers['Authorization'] and time < 3600.0)
      end

      def valid_user_params?(u_params)
        u_params = u_params.select { |k,v| !v.nil?}
      end

      def guns_params
        params.permit(:name, :gun_type, :caliber, :serial_number, :sound)
      end
  end
end