module UsersHelper
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by_uuid(params[:uuid])
    render json: { error: 'Пользователь не найден'}, status: 404 unless @user
  end

  def user
    @user ||= User.find_by_uuid(params[:uuid])
  end 

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :last_name, :login, :email, :phone_number, :password, :uuid, :parameters)
  end

  def generate_token
    # session[:token_time] = Time.now
    session[:token] = SecureRandom.hex(32)
    session[:uuid] = @user.uuid
    {token: session[:token]}
  end

  def check_token
    Rails.logger.debug "headers: #{request.headers['Authorization']}"
    # Проверка времени убрана из-за особенностей работы с мобильным приложением
    # time = Time.now - (session[:token_time]&.to_time || Time.at(0))
    if !session[:token] == request.headers['Authorization']
      render json: { 'error': 'token error' }, status: 403 unless session[:token] == request.headers['Authorization']
    elsif params[:uuid].present? && session[:uuid] != params[:uuid]
      render json: { 'error': 'token error' }, status: 403  unless params[:uuid].present? && session[:uuid] != params[:uuid]
    end
  end

  def valid_user_params?(u_params)
    u_params = u_params.select { |k,v| !v.nil?}
  end
end
