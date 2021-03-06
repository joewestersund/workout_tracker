# == Schema Information
#
# Table name: default_data_points
#
#  id                 :bigint           not null, primary key
#  decimal_value      :decimal(, )
#  text_value         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  data_type_id       :bigint
#  dropdown_option_id :bigint
#  route_id           :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_ddp_on_do                        (dropdown_option_id)
#  index_ddp_on_dt                        (data_type_id)
#  index_default_data_points_on_route_id  (route_id)
#  index_default_data_points_on_user_id   (user_id)
#
class DefaultDataPoint < ApplicationRecord
  belongs_to :user
  belongs_to :route
  belongs_to :data_type
  belongs_to :dropdown_option, optional: true

  validates :user_id, presence: true
  validates :route_id, presence: true
  validates :data_type_id, presence: true

  validate :one_of_three_is_present

  def one_of_three_is_present
    count = 0
    count += 1 if dropdown_option_id.present?
    count += 1 if decimal_value.present?
    count += 1 if text_value.present?
    if count == 0
      self.errors.add :base, "The value cannot be blank."
    elsif count > 1
      self.errors.add :base, "Only one value should be supplied, in either text, decimal or dropdown option id format."
    end
  end

  def value_to_s
    if dropdown_option_id.present?
      val = self.dropdown_option.name
    elsif text_value.present?
      val = text_value
    else
      val = decimal_value
    end
    val
  end

  def to_s
    "#{self.data_type.name}: #{self.value_to_s}"
  end

  def apply_to_existing_data_points(overwrite_non_nil_values = false)
    current_user.routes.find(self.route_id).workout_routes.each do |wr|
      dps = current_user.data_points.where(workout_route: wr, data_type: self.data_type)
      if dps.present? and overwrite_non_nil_values
        dps.each do |dp|
          # there are some existing data points. Copy values over
          dp.copy_values_from(self)
          dp.save
        end
      else
        # there isn't an existing data point for this workout_route that would correspond to this default data point.
        # so, create one and copy the important values over.
        dp = DataPoint.create_from(self)
        dp.save
      end
    end

  end
end
