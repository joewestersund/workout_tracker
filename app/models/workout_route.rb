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

  validates :user_id, presence: true
  validates :workout_id, presence: true
  validates :route_id, presence: true

  def WorkoutRoute.create_from_defaults(route)
    wr = WorkoutRoute.new
    wr.user = route.user
    wr.route = route
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
    self.route.workout_type.data_types.order(:order_in_list).each do |dt|
      if self.data_points.find_by(data_type: dt).nil?
        # we don't have a current data point for this data type
        ddp = route.default_data_points.find_by(data_type: dt)
        if ddp.present?
          wr.data_points << DataPoint.create_from_default(ddp)
        else
          wr.data_points << DataPoint.create_from_data_type(dt)
        end
      end
    end
  end

  def to_builder
    Jbuilder.new do |json|
      json.route_id self.route_id
      json.route_name self.route.name
      json.data_points self.data_points do |dp|
        dt = dp.data_type
        json.data_type_id dt.id
        json.data_type_name dt.name
        json.is_dropdown dt.is_dropdown?
        json.value dp.value
        if dt.is_dropdown?
          json.options dt.dropdown_options.order(:order_in_list) do |opt|
            json.option_id opt.id
            json.option_name opt.name
          end
        end
      end
    end
  end

end
