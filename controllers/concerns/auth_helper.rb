module AuthHelper
  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      auth_user_impl(options[:id], token)
    end

    auth_user_impl(params[:id], params[:token]) unless current_user
  end

  def auth_user_impl(id, token)
    #puts "Searching for user with id = #{id}, token = #{token}"
    user = User.find_by(id: id)

    if user && Devise.secure_compare(user.authentication_token, token)
      @current_user = user
    else
      render json: {message: 'Forbidden'}, status: 403
    end
  end

  def set_origin
    request.headers['origin'] = 'http://hiring-pro.com'
  end
end