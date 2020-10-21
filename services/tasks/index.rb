module Tasks
  class Index < BaseService
    attr_accessor :city, :category, :order, :s_query, :current_page, :tasks, :per_page

    def initialize(city_id, category_id, order, s_query, current_page = 1, per_page = 10)
      @city = City.find_by(id: city_id)
      @category = Category.find_by(id: category_id)
      @order = order
      @s_query = s_query
      @current_page = current_page || 1
      @per_page = per_page || 10
      @tasks = Task.visible
    end

    def call
      filter_city
      filter_category
      sort
      search
      paginate
      tasks
    end

    private

    def filter_city
      self.tasks = tasks.where(city_id: city.id) if city
    end

    def filter_category
      if category
        keys = category.root? ? category.children.pluck(:id) : category.id
        self.tasks =  tasks.where(category_id: keys)
      end
    end

    def search
      self.tasks = tasks.search_everywhere(s_query) if s_query
    end

    def paginate
      self.tasks = tasks.paginate(page: current_page, per_page: per_page)
    end

    def sort
      case order
      when 'date'
        self.tasks
      when 'price'
        self.tasks = tasks.order(:price)
      else
        self.tasks
      end
    end
  end
end
