class Api::V1::TaskRequestsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :get_task_request, only: [:update, :destroy, :approve]

  # get related tasks
  def index
    result = TaskRequest.where(user_id: current_user.id, state: :active).includes(:task).paginate(page: params[:page], per_page: params[:per_page])
    render_item(result, 'TaskRequestSerializer',{}, params[:include].to_s.split(","), { total_pages: result.total_pages, total_length: result.count })
  end

  # user create request on task
  def create
    result = TaskRequests::Create.new(current_user, task_request_params).call
    render_response(result)
  end

  # user update attributes on his task
  def update
    prm = task_request_params
    prm.extract!(:task_id)
    result = TaskRequests::Update.new(current_user, prm, @task_request).call
    render_response(result)
  end

  # user destroy his task
  def destroy
    result = TaskRequests::Destroy.new(current_user, @task_request).call
    render_response(result)
  end

  # task creator approve task_request for his task
  def approve
    result = TaskRequests::Approve.new(current_user, @task_request).call
    render_response(result)
  end

  private

  def task_request_params
    params.require(:task_request).permit(:task_id, :price, :message)
  end

  def get_task_request
    @task_request = TaskRequest.find(params[:id])
  end
end