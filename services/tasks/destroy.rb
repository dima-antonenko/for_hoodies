module Tasks
  class Destroy < BaseService
    attr_accessor :current_user, :task
    include UserValidations
    include TaskValidations

    def initialize(current_user, task)
      @current_user, @task = current_user, task
    end

    def call
      validate!
      task.update_attribute(:deleted, true)
      task
    end

    private

    def validate!
      user_active?(current_user)
      task_not_deleted?(task)
      user_has_access?(current_user, task)
      task_not_approved?(task)
      task_completion_date_not_come?(task)
    end
  end
end