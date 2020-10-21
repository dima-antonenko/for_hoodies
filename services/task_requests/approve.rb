module TaskRequests
  class Approve < BaseService
    include UserValidations
    include TaskRequestValidations
    include TaskValidations

    attr_reader :current_user, :task_request

    def initialize(current_user, task_request)
      @current_user, @task_request = current_user, task_request
    end

    def call
      validate!
      update_states
      task_request
    end

    private

    def update_states
      task_request.approved!
      task_request.task.task_requests.where.not(state: :approved).update_all({state: :rejected})
      task_request.task.performed!
    end

    def validate!
      user_active?(current_user)
      task = task_request.task
      task_active?(task)
      task_has_valid_completion?(task)
      request_has_valid_state?(task_request)
      user_owner_task?(current_user, task)
    end
  end
end