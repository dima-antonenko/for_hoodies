class BaseService
  protected

  def save_and_return(record, &block)
    if record.valid?
      record.save
      block&.call if block_given?
      record.reload
      record
    else
      record.errors
    end
  end

  def increase_rating(user, points, old_points = nil)
    user.total_rating -= old_points if old_points
    user.total_rating += points
    user.reviews_qty += 1 if !old_points
    recalc_rating(user)
  end

  def decrease_rating(user, points)
    user.total_rating -= points
    user.reviews_qty -= 1
    recalc_rating(user)
    user.attributes
  end

  def recalc_rating(user)
    if user.reviews_qty == 0
      user.rating = 0
    else
      user.rating = user.total_rating / user.reviews_qty
    end
    user.save!
  end
end