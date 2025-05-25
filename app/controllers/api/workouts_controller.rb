module Api
  class WorkoutsController < ApplicationController
    include UsersHelper

    skip_before_action :verify_authenticity_token
    before_action :check_token, except: [:index, :show]

    def index
      render json: Workout.all
    end

    def future
      render json: Workout.where("start_time > ?", Time.now)
    end

    def show
      render json: present(Workout.find_by_id(params[:id].to_i))
    end

    def create
      begin
        time = params['time']
        start_time = Time.local(time['year'], time['month'], time['day'], time['hour'], time['min'])
        avtorize_coach_or_admin(user, @workout)
        @workout = Workout.create!(workout_params.merge({ start_time: start_time, club: Club.find(params['club_id'].to_i)}))
        @workout.update!(open: false) if @workout.student.present?
        render json: present(@workout), status: 201
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def update
      @workout = Workout.find_by_id(params[:id].to_i)
      begin
        avtorize_coach_or_admin(user, @workout)
        if params['time'].present?
          time = params['time']
          start_time = DateTime.new(time['year'], time['month'], time['day'], time['hour'], time['min'])
          @workout.update!(workout_params.merge({ start_time: start_time }))
          @workout.update!(open: false) if @workout.student.present?
        else
          @workout.update!(workout_params)
        end
        render json: present(@workout)
      rescue => e
        render json: { error: e.message }, status: 401
      end
    end

    def delete
      @workout = Workout.find_by_id(params[:id].to_i)&.delete
      avtorize_coach_or_admin(user, @workout)
      render json: { success: :deleted }, status: 204
    end

    def sign_up
      @workout = Workout.find_by_id(params[:id].to_i)
      if @workout.open
        student = User.find_by_uuid(session[:uuid])
        @workout.update!(student_id: student.id)
        render json: present(@workout)
      else
        render json: { error: 'на тренировку уже нельзя записаться'}
      end
    end

    private

    def avtorize_coach_or_admin(user, workout)
      club_id = workout.club_id
      avtorize = user&.admin_for?(club_id) || user&.coach_for?(club_id)
      raise 'Авторизованный пользователь не имеет достаточно прав' unless avtorize
    end

    def workout_params
      params.require(:workout).permit(:coach_id, :student_id, :club, :need_gun, :open)
    end

    def user
      @user ||= User.find_by_uuid(session[:uuid])
    end

    def present(workout)
      result = JSON.parse(workout.to_json)
      result["coach_id"] = User.find(result["coach_id"] ).uuid
      result["student_id"] = User.find(result["student_id"] ).uuid
      result
    end
  end
end
 