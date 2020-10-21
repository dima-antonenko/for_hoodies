class TaskRequestSerializer
  include FastJsonapi::ObjectSerializer

  attributes :price, :message, :state, :created_at, :deleted

  belongs_to :task
end