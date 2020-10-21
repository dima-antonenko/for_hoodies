module TaskValidations
  # время на выполнения задачи, устанавливается в Tasks::Create
  MAX_EXECUTION_TIME = 180.days
  MAX_CREATE_REVIEW_TIME = 10.days

  def task_completed?(task)
    raise PermissionError.new(:state, 'This task not completed') if !task || !task.completed?
  end

  def task_active?(task)
    raise PermissionError.new(:state, 'This task not active') if !task || task.deleted
  end

  def task_has_valid_time?(task)
    raise PermissionError.new(:completed_at, 'You can leave feedback only within 10 days') if task.completed_at < MAX_CREATE_REVIEW_TIME.ago
  end

  # блокировка задач с прошедшим completed_at
  # Tasks::Destroy
  def task_completion_date_not_come?(task)
    raise PermissionError.new(:completion_date,'Task completed time already passed') if task.completion_date < DateTime.now
  end

  # максимальное время выполнения задачи
  # Tasks::Create & Tasks::Update
  def task_has_valid_completion?(task)
    raise PermissionError.new(:completion_date, 'Invalid completion date') if
        task.completion_date > (DateTime.now + MAX_EXECUTION_TIME) || task.completion_date < DateTime.now
  end

  def user_related_with_task?(user, task)
    raise PermissionError.new(:user_id, 'User not related for this task') if task.task_requests.where(user_id: user.id).size == 0
  end

  # TaskRequests::Create
  def user_not_related_with_task(user, task)
    raise PermissionError.new(:user_id, 'User related for this task') if task.task_requests.where(user_id: user.id).size != 0
  end

  def user_complete_task?(user, task_request)
    raise PermissionError.new(:state, 'User cannot complete task') if !task_request.completed? || task_request.user_id != user.id
  end

  def user_owner_task?(user, task)
    raise PermissionError.new(:user_id, 'You not creator of his task') if task.user_id != user.id
  end

  # TaskRequests::Create
  def user_not_owner_task?(user, task)
    raise PermissionError.new(:user_id, 'You cannot add request to his task') if task.user_id == user.id
  end

  # позволяет ли состояние задачи обновлять его
  # Tasks::Update
  def task_has_not_modifined_state?(task)
    raise PermissionError.new(:state, 'Task has invalid state') unless task.active?
  end

  # Tasks::Update&Complete
  def task_not_deleted?(task)
    raise PermissionError.new(:state, 'You cannot update deleted task') if !task || task.deleted
  end

  # Tasks::Update
  def user_has_access?(user, task)
    raise PermissionError.new(:user_id, 'You not creator of this task') if task.user_id != user.id
  end

  def task_not_completion?(task)
    raise PermissionError.new(:completion_date, 'Task has invalid completaion_dta') if task.completion_date >
        (DateTime.now + MAX_EXECUTION_TIME)
  end

  # Tasks::Complete
  def task_not_approved?(task)
    task_has_approved_requests = task.task_requests.where(state: :approved).size > 0
    raise PermissionError.new(:state,'You cannot delete approved task') if task.performed? || task_has_approved_requests
  end

  # дата начала должна быть раньше даты завершения
  # Tasks::Create
  def task_start_date_valid?(task)
    if task.start_date
      msg = "Start date can`t be more than completion_date"
      msg << "start: #{task.start_date} completion: #{task.completion_date}"
      raise ParamsValidationError.new(:completion_date, msg) if task.start_date > task.completion_date
    end
  end

  def payment_type_valid?(payment_type)
    raise ParamsValidationError.new(:payment_type, "Invalid payment_type: #{payment_type}") unless (0...1).include?(payment_type)

  end
end