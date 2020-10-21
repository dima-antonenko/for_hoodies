module TaskRequestValidations
  def request_has_valid_state?(task_request)
    raise PermissionError.new(:state,'You cannot update approved or deleted task_request') if task_request.deleted
  end

  def user_owner_request?(user, task_request)
    raise PermissionError.new(:user_id,'You cannot update not his task_request') if task_request.user_id != user.id
  end

  def task_request_first?(user, task)
    raise PermissionError.new(:user_id,'You already add task request to this tak') if task.task_requests.where(user_id: user.id).size != 0
  end

  def task_request_completed?(task_request)
    raise PermissionError.new(:state,'Task request not completed') unless task_request.completed?
  end

  def task_request_approved?(task_request)
    raise PermissionError.new(:state, 'You cannot update approved task requests') if task_request.approved?
  end
end
