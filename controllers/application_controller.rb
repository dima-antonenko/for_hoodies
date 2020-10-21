class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include AuthHelper
  include ExceptionsHelper
  include PrettyResponse

  skip_before_action :verify_authenticity_token, if: :json_request?

  # prepend_before_action :delay_processing
  prepend_before_action :set_origin, if: Proc.new { Rails.env.production? }

  respond_to :json

  private

  def delay_processing
    sleep 1.4
  end

  # @todo перенести обработку исключений в ExceptionsHelper
  # @todo разобраться почему появляется ошибка
  # NoMethodError: undefined method `rescue_from' for ExceptionsHelper:Module

  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      # puts "Authenticating from token, token= #{token}, options: #{options}"
      auth_user_impl(options[:email], token)
    end

    auth_user_impl(params[:email], params[:token]) unless current_user
  end

  def auth_user_impl(email, token)
    user = User.find_by(email: email)

    if user && Devise.secure_compare(user.authentication_token, token)
      bypass_sign_in user
    end
  end

  # def current_user
  #   @current_user
  # end

  def fictive_admin
    User.find_by(email: 'fictive_admin@test.ru')
  end

  def set_origin
    request.headers['origin'] = 'http://hiring-pro.com'
  end

  rescue_from 'RelationError' do |exception|
    render json: {errors: exception.call}, status: 500
  end

  rescue_from 'PermissionError' do |exception|
    render json: {errors: exception.call}, status: 422
  end

  rescue_from 'ParamsValidationError' do |exception|
    render json: {errors: exception.call}, status: 422
  end

  rescue_from 'ForbiddenError' do |exception|
    render json: {errors: exception.call}, status: 500
  end

  rescue_from 'ActiveRecord::RecordNotFound'  do |exception|
    render json: {errors: 'Record not found'}, status: 404
  end

  def json_request?
    request.format.json?
  end
end
