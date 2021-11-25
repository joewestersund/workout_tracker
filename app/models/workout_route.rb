# == Schema Information
#
# Table name: workout_routes
#
#  id          :bigint           not null, primary key
#  description :text
#  repetitions :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  route_id    :bigint
#  user_id     :bigint
#  workout_id  :bigint
#
# Indexes
#
#  index_workout_routes_on_route_id    (route_id)
#  index_workout_routes_on_user_id     (user_id)
#  index_workout_routes_on_workout_id  (workout_id)
#
class WorkoutRoute < ApplicationRecord
  belongs_to :user
  belongs_to :workout
  belongs_to :route

  has_many :data_points, dependent: :destroy

  # The set_defaults will only work if the object is new
  after_initialize :set_defaults, unless: :persisted?

  validates :user_id, presence: true
  validates :workout_id, presence: true
  validates :route_id, presence: true
  validates :repetitions, numericality: { only_integer: true, greater_than: 0 }

  def set_defaults
    self.repetitions = 1
  end

  def WorkoutRoute.create_from_defaults(workout, route)
    wr = WorkoutRoute.new
    wr.user = route.user
    wr.route = route
    wr.workout = workout
    route.workout_type.data_types.order(:order_in_list).each do |dt|
      ddp = route.default_data_points.find_by(data_type: dt)
      if ddp.present?
        wr.data_points << DataPoint.create_from_default(ddp)
      else
        wr.data_points << DataPoint.create_from_data_type(dt)
      end
    end
    wr   # return the new object
  end

  def apply_defaults
    # apply the defaults to this route, not overwriting any data point values that exist
    self.route.workout_type.data_types.where(active: true).order(:order_in_list).each do |dt|
      if self.data_points.find_by(data_type: dt).nil?
        # for an existing workout_route, don't apply default data points. That's only for templates for new wr.
        dp = DataPoint.create_from_data_type(dt)
        dp.workout_route = self
        self.data_points << dp
      end
    end
  end

  def to_builder
    # need to sort data points so they appear in correct order in ui
    # can't do with join if some of the data points aren't saved to the database (were created from default / data type)
    dp_array = self.data_points.map{ |dp| dp.data_type.active? ? dp : nil }
        .compact
        .sort_by { |dp| dp.data_type.order_in_list }

    Jbuilder.new do |json|
      json.workout_route_id self.id
      json.route_id self.route_id
      json.route_name self.route.name
      json.repetitions self.repetitions
      json.data_points dp_array do |dp|
        json.data_type_id dp.data_type_id
        json.value dp.value
      end
    end
  end

end
