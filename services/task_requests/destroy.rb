module TaskRequests
  class Destroy < BaseService
    include UserValidations
    include TaskValidations
    include TaskRequestValidations

    attr_accessor :current_user, :task_request

    def initialize(current_user, task_request)
      @current_user, @task_request = current_user, task_request
    end

    def call
      validate!
      task_request.update_attribute(:deleted, :true)
      task_request
    end

    private

    def validate!
      user_active?(current_user)
      task = task_request.task
      task_active?(task)
      task_request_approved?(task_request)
      request_has_valid_state?(task_request)
      user_owner_request?(current_user, task_request)
    end
  end
end
