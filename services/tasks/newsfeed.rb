module Tasks
  class Newsfeed < BaseService
    include UserValidations

    attr_accessor :user, :tasks

    def initialize(user, current_page = 1)
      @user = user
      @tasks = Task.active.where(city_id: user&.city_id)
      @current_page = current_page
    end

    def call
      validate!
      filter_cities
      filter_categories
      paginate
      tasks
    end

    private

    def validate!
      user_active?(user)
    end

    def filter_cities
      self.tasks = tasks.where(city_id: user.bookmark_city_ids) unless user.bookmark_city_ids.empty?
    end

    def filter_categories
      self.tasks = tasks.where(city_id: user.bookmark_category_ids) unless user.bookmark_category_ids.empty?
    end

    def paginate
      self.tasks = tasks.paginate(page: @current_page, per_page: 10)
    end
  end
end
