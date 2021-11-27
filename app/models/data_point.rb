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
      self.errors.add :base, "The value cannot be blank."
    elsif count > 1
      self.errors.add :base, "Only one value should be supplied, in either text, decimal or dropdown option id format."
    end
  end

  def value
    if dropdown_option_id.present?
      val = dropdown_option_id
    elsif text_value.present?
      val = text_value
    else
      if self.data_type.is_hours_minutes? || self.data_type.is_minutes_seconds?
        val = self.data_type.convert_from_number(decimal_value)
      else
        val = decimal_value
      end
    end
    val
  end

  def value_to_s
    if dropdown_option_id.present?
      val = self.dropdown_option.name
    elsif text_value.present?
      val = text_value
    else
      if self.data_type.is_hours_minutes? || self.data_type.is_minutes_seconds?
        val = self.data_type.convert_from_number(decimal_value)
      else
        val = decimal_value
      end
    end
    val
  end

  def to_s
    "#{self.data_type.name}: #{self.value_to_s}"
  end

  def set_value(value)
    dt = self.data_type
    if dt.is_dropdown?
      self.dropdown_option_id = value
    elsif dt.is_text?
      self.text_value = value
    elsif dt.is_numeric?
      self.decimal_value = value
    elsif dt.is_hours_minutes? || dt.is_minutes_seconds?
      self.decimal_value = dt.convert_to_number(value)
    else
      raise "could not set value #{value}"
    end
  end

  def DataPoint.create_from_data_type(data_type)
    #dp = data_type.data_points.build(user: data_type.user)
    dp = DataPoint.new
    dp.user = data_type.user
    dp.data_type = data_type
    dp   # return the new object
  end

  def DataPoint.create_from_default(default_data_point)
    #dp = default_data_point.data_type.data_points.build(user: default_data_point.user)
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
