module Tasks
  class Create < BaseService
    include UserValidations
    include TaskValidations
    include CategoryValidations
    attr_accessor :user, :params, :task, :category

    def initialize(user, params)
      @user = user
      @params = params.merge({payment_type: params[:payment_type].to_i})
      @category = Category.find_by(id: params[:category_id])
      @task = Task.new
    end

    def call
      pre_validate!
      assign!
      post_validate!
      save_and_return(task)
    end

    private

    def assign!
      task.assign_attributes(params.merge({user_id: user&.id, city_id: user&.city_id}))
      task.completion_date = DateTime.now + category&.default_duration_days.days unless task.completion_date
    end

    def pre_validate!
      user_active?(user)
      payment_type_valid?(params[:payment_type])
      category_exist?(category)
    end

    def post_validate!
      task_start_date_valid?(task)
      task_has_valid_completion?(task)
    end
  end
end
