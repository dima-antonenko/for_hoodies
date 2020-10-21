class TaskSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :description, :service_location, :price, :payment_type, :start_date,
             :completion_date, :state, :deleted, :completed_at

  has_many :task_requests, if: Proc.new { |task, params| params && params[:current_user].try(:id) == task.user_id }
  has_many :reviews

  belongs_to :city
  belongs_to :category
  belongs_to :user

  belongs_to :task_request, if: Proc.new { |task, params| !params.try(:[], :current_user).blank? } do |task, params|
    task.task_requests.where(user_id: params[:current_user].id).last
  end

  attribute :avatar_full_path do |task|
    if task.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_path(task.avatar, only_path: true)
    else
      '/static_data/noimage/noimage.png'
    end
  end

  attribute :responded_for_current_user do |task, params|
    if params[:current_user]
      task.task_requests.where(user_id: params[:current_user].id, state: :active).size > 0
    else
      'user not authorized'
    end
  end
end
