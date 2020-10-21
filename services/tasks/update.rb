module Tasks
  class Update < BaseService
    attr_accessor  :params, :task, :current_user
    include UserValidations
    include TaskValidations

    def initialize(current_user, task, params)
      @current_user, @task, @params = current_user, task, params
    end

    # @todo дописать логирование состояния полей до и после обновления
    # @todo ограничить количество обновлений за единицу времени
    def call
      validate!
      task.assign_attributes(params)
      save_and_return(task)
    end

    def validate!
      user_active?(current_user)
      task_has_not_modifined_state?(task)
      task_not_deleted?(task)
      task_has_valid_completion?(task)
      user_has_access?(current_user, task)
    end
  end
end