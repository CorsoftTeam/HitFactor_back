module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
    #before_action :set_user, only: %i[ show edit update destroy ]

    # GET /users or /users.json
    def index
      render json: { "error": "мы не показываем список всех пользователей"}
    end

    # GET /users/1 or /users/1.json
    def show
      check_token
      @user = User.find_by_uuid(params[:id]) || { error: 'Пользователь не найден'}
      render json: @user
    end

    def get_me
      check_token
      @user = User.find_by_uuid(session[:id]) || { error: 'Пользователь не найден'}
      render json: @user
    end

    # GET /users/new
    def new
      @user = User.new
    end

    # GET /users/1/edit
    def edit
    end

    # POST /users or /users.json
    def create
      p "params = #{params}. Это nil? - #{params.nil?}"
      if valid_user_params?(user_params)
        @user = User.create!(user_params)
        @user.set_uuid
        render json: generate_token, status: 201
      else
        render json: { "error": "Ошибка в параметрах пользователя" }, code: 401
      end
    end

    # PATCH/PUT /users/1 or /users/1.json
    def update
      check_token
      set_user
      @user.update!(user_params)
      render json: @user
    end

    # DELETE /users/1 or /users/1.json
    def destroy
      check_token
      set_user
      @user.destroy!
    end

    def authorization
      @user = User.find_by(login: params[:login], password: params[:password])
      if @user
        render json: generate_token
      else
        render json: { "error": 'no_this_user' }, status: 401
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find_by_uuid(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def user_params
        p "params = #{params}. Это nil? - #{params.nil?}"
        params.require(:user).permit(:name, :last_name, :login, :email, :phone_number, :password, :uuid, :parameters)
      end

      def generate_token
        session[:token_time] = Time.now
        session[:token] = SecureRandom.hex(32)
        session[:id] = @user.uuid
        {token: session[:token]}
      end

      def check_token
        time = Time.now - session[:token_time].to_time
        render json: { "error": "неправильный токен" }, status: 403 unless session[:token] == request.headers['Authorization'] and time < 3600.0
      end

      def valid_user_params?(u_params)
        u_params = u_params.select { |k,v| !v.nil?}
      end
  end
end