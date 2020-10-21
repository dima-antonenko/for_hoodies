module TaskRequests
  class Create < BaseService
    include UserValidations
    include TaskValidations
    include TaskRequestValidations

    attr_accessor :current_user, :params, :task, :task_request

    def initialize(current_user, params)
      @current_user, @params = current_user, params
      @task_request = TaskRequest.new(user_id: current_user&.id)
      @task = Task.find_by(id: params[:task_id])
    end

    def call
      validate!
      task_request.assign_attributes(params)
      save_and_return(task_request)
    end

    protected

    def validate!
      user_active?(current_user)
      task_active?(task)
      user_not_owner_task?(current_user, task)
      user_not_related_with_task(current_user, task)
    end

    private

    def task_request_valid?
      task.task_requests.where(user_id: current_user.id).size == 0
    end

    def user_valid?
      task.user.id != current_user.id
    end
  end
end