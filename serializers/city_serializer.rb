class CitySerializer
  include FastJsonapi::ObjectSerializer

  attributes :title

  has_many :tasks
  has_many :users
end