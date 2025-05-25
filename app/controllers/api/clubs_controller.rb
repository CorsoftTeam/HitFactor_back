module Api
  class ClubsController < ApplicationController
    include UsersHelper

    skip_before_action :verify_authenticity_token
    before_action :check_token, except: [:index, :show]
    before_action :authorize_admin, except: [:index, :show, :create]

    def index
      render json: Club.all
    end

    def show
      render json: Club.find_by_id(params[:id].to_i)
    end
    
    def create
      Rails.logger.debug "headers: #{request.headers['Authorization']}"
      begin
        admin = User.find_by_uuid(session[:uuid])
        render json: { error: @club.errors }, status: 404 unless admin
        @club = Club.create!(club_params)
        admin_for = admin.parameters.send('[]', 'admin_for') || []
        admin_for << @club.id
        admin.update!(parameters: admin.parameters.merge({ 'admin_for': admin_for}))
        render json: @club, status: :created
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def update
      begin
        @club = Club.find(params[:id])
        @club.update!(club_params)
        render json: @club, status: :ok
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def add_admin
      begin
        admin = User.find_by_uuid(params[:admin_uuid])
        admins_list = admin.parameters&['admin_for'] || []
        if admins_list.kind_of?(Array)
          admins_list.add(params[:id].to_i) unless admins_list.include?(params[:id].to_i)
          admin.update!
        end
        render json: { 'success': 'admin added' }, status: 201
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def add_coach
      begin
        coach = User.find_by_uuid(params[:coach_uuid])
        coach_list = admin.parameters&['coach_for'] || []
        if coach_list.kind_of?(Array)
          coach_list.add(params[:id].to_i) unless coach_list.include?(params[:id].to_i)
          coach.update!
        end
        render json: { success: 'coach added' }, status: :created
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def delete_admin
      begin
        admin = User.find_by_uuid(params[:admin_uuid])
        admins_list = admin.parameters&['admin_for'] || []
        if admins_list.kind_of?(Array)
          admins_list.delete(params[:id].to_i)
        end
        render json: { 'success': 'admin deleted'}, status: :deleted
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def delete_coach
      begin
        coach = User.find_by_uuid(params[:coach_uuid])
        coach_list = admin.parameters&['coach_for'] || []
        if coach_list.kind_of?(Array)
          coach_list.delete(params[:id].to_i)
        end
        render json: { 'success': 'coach deleted'}, status: :deleted
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    private

    def authorize_admin
      user = User.find_by_uuid(session[:uuid])
      render json: { 'error': 'Авторизованный пользователь не админ для клуба' }, status: 404 unless user&.admin_for?(params[:id])
    end

    def club_params
      params.require(:club).permit(:name, :address, :phone, :open_time_workday,
                                                            :close_time_workday,
                                                            :open_time_weekend,
                                                            :close_time_weekend)
    end
  end
end
