module Api
  class UsersController < ApplicationController
    before_action :set_user, only: %i[ show edit update destroy ]

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
      @user = User.new(user_params)
      render json: @user
    end

    # PATCH/PUT /users/1 or /users/1.json
    def update
      @user = User.find(params[:id].to_i)
      @user.update!(params.deep_symbolize_keys)
      render json: @user
    end

    # DELETE /users/1 or /users/1.json
    def destroy
      @user.destroy!
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
  end
end