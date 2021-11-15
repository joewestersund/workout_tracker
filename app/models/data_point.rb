# == Schema Information
#
# Table name: data_points
#
#  id                 :bigint           not null, primary key
#  decimal_value      :decimal(, )
#  text_value         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  data_type_id       :bigint
#  dropdown_option_id :bigint
#  user_id            :bigint
#  workout_route_id   :bigint
#
# Indexes
#
#  index_adtv_on_adt                      (data_type_id)
#  index_adtv_on_adto                     (dropdown_option_id)
#  index_data_points_on_user_id           (user_id)
#  index_data_points_on_workout_route_id  (workout_route_id)
#
class DataPoint < ApplicationRecord
  belongs_to :user
  belongs_to :workout_route
  belongs_to :data_type
  belongs_to :dropdown_option, optional: true

  validates :user_id, presence: true
  validates :workout_route_id, presence: true
  validates :data_type_id, presence: true

  validate :one_of_three_is_present

  def one_of_three_is_present
    count = 0
    count += 1 if dropdown_option_id.present?
    count += 1 if decimal_value.present?
    count += 1 if text_value.present?
    if count == 0
      record.errors.add :base, "No text, decimal or dropdown option id value was supplied."
    elsif count > 1
      record.errors.add :base, "Only one value should be supplied, in either text, decimal or dropdown option id format."
    end
  end

  def to_s
    if dropdown_option_id.present?
      val = self.dropdown_option.name
    elsif text_value.present?
      val = text_value
    else
      val = decimal_value
    end
    "#{self.data_type.name}: #{val}"
  end

  def DataPoint.create_from(default_data_point)
    dp = DataPoint.new
    dp.user = default_data_point.user
    dp.data_type = default_data_point.data_type
    dp.copy_values_from(default_data_point)
    dp   # return the new object
  end

  def copy_values_from(default_data_point)
    self.decimal_value = default_data_point.decimal_value
    self.text_value = default_data_point.text_value
    self.dropdown_option = default_data_point.dropdown_option
  end

end