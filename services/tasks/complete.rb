module Tasks
  class Complete < BaseService
    include TaskValidations
    attr_accessor :current_user, :task

    def initialize(current_user, task)
      @current_user, @task = current_user, task
    end

    def call
      validate!
      task.assign_attributes({state: 2, completed_at: DateTime.now})
      task.task_requests.find_by(state: :approved).completed! # @todo покрыть тестом
      save_and_return(task)
    end

    private

    def validate!
      task_not_deleted?(task)
      user_has_access?(current_user, task)
      task_has_approved_requests(task)
      # @todo возможно стоит валидировать даты выполнения
    end

    def task_has_approved_requests(task)
      task_request = task.task_requests.where(state: :approved).first
      raise PermissionError.new('Task not has approved requests') if !task_request || task_request.user.deleted
    end
  end
end