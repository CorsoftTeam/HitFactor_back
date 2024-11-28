module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
    #before_action :set_user, only: %i[ show edit update destroy ]

    # GET /users or /users.json
    def index
      @users = User.all
      render json: @users
    end

    # GET /users/1 or /users/1.json
    def show
      @user = User.find(params[:id].to_i)
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
      @user = User.create!(user_params)
      render json: @user
    end

    # PATCH/PUT /users/1 or /users/1.json
    def update
      check_token
      @user = User.find(params[:id].to_i)
      @user.update!(params.deep_symbolize_keys)
      render json: @user
    end

    # DELETE /users/1 or /users/1.json
    def destroy
      check_token
      @user.destroy!
    end

    def authorization
      @user = User.find_by(login: params[:login], password: params[:password])
      if @user
        render json: generate_token
      else
        render json: {error: 'no_this_user'}
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def user_params
        params.require(:user).permit(:name, :last_name, :login, :email, :phone_number, :password, :uuid, :parameters)
      end

      def generate_token
        session[:token_time] = Time.now
        session[:token] = SecureRandom.hex(10)
        {tocken: session[:token]}
      end

      def check_token
        raise 'invalid token' unless session[:token] == params[:tocker] and (Time.now - session[:token_time]) < 3600
      end
  end
end