class Api::V1::TasksController < ApplicationController
  before_action :authenticate_user_from_token!, only: [:create, :update, :destroy, :complete, :show, :my, :newsfeed]
  before_action :get_task, only: [:update, :destroy, :complete, :show]

  def index
    tasks = Tasks::Index.new(params[:city_id], params[:category_id], params[:order], params[:s_query], params[:page], params[:per_page]).call
    render_item(tasks, 'TaskSerializer', {}, params[:include].to_s.split(","), { total_pages: tasks.total_pages, total_length: tasks.count })
  end

  def my
    tasks = Task.where(user_id: current_user.id).paginate(page: params[:page], per_page: params[:per_page])
    render_item(tasks, 'TaskSerializer', {}, params[:include].to_s.split(","), { total_pages: tasks.total_pages, total_length: tasks.count })
  end

  def newsfeed
    tasks = Tasks::Newsfeed.new(current_user, params[:current_page]).call
    render_item(tasks, 'TaskSerializer', {include: params[:include].to_s.split(",")},
                params[:include].to_s.split(","))
  end

  def create
    result = Tasks::Create.new(current_user, task_params).call
    render_response(result)
  end

  def update
    result = Tasks::Update.new(current_user, @task, task_params_for_update).call
    render_response(result)
  end

  def destroy
    result = Tasks::Destroy.new(current_user, @task).call
    render_response(result)
  end

  # @todo продумать логику когда создатель задачи забыл про задачу на длительное время
  def complete
    result = Tasks::Complete.new(current_user, @task).call
    render_response(result)
  end

  def show
    render_item(@task, 'TaskSerializer', {}, params[:include].to_s.split(","))
  end

  private

  def get_task
    @task = Task.visible.find(params[:id])
  end

  def task_params_for_update
    params.require(:task).permit(:title, :description, :price, :service_location, :start_date,
                                 :completion_date, :city_id)
  end

  def task_params
    params.require(:task).permit(:title, :description, :price, :start_date, :completion_date, :payment_type,
                                 :category_id, :service_location)
  end
end
