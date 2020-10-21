class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :phone

  belongs_to :city
  has_many :tasks
  has_many :reviews, foreign_key: "recipient_id"
  has_many :tickets

  attribute :avatar_full_path do |user|
    if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
    else
      '/static_data/noimage/noimage.png'
    end
  end

  attribute :bookmark_categories do |user|
    Category.where(id: user.bookmark_category_ids).collect{|c| {id: c.id, title: c.title}}
  end

  attribute :bookmark_cities do |user|
    City.where(id: user.bookmark_city_ids).collect{|c| {id: c.id, title: c.title}}
  end
end
