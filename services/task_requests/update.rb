module TaskRequests
  class Update < BaseService
    include UserValidations
    include TaskValidations
    include TaskRequestValidations

    attr_accessor :current_user, :params, :task, :task_request

    def initialize(current_user, params, task_request)
      @current_user, @params, @task_request = current_user, params, task_request
      @task = task_request.task
    end

    def call
      validate!
      task_request.assign_attributes(params)
      save_and_return(task_request)
    end

    private

    def validate!
      user_active?(current_user)
      task_request_approved?(task_request)
      task_active?(task_request.task)
      request_has_valid_state?(task_request)
      user_owner_request?(current_user, task_request)
    end
  end
end
