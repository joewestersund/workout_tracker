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
  belongs_to :dropdown_option

  validates :user_id, presence: true
  validates :workout_id, presence: true
  validates :data_type_id, presence: true

  validate :one_of_three_is_present

  def one_of_three_is_present
    count = 0
    count += 1 if dropdown_option_id.present?
    count += 1 if decimal_value.present?
    count += 1 if text_value.present?
    if count == 0
      record.errors.add :base, "No text, decimal or option_id value was supplied."
    elsif count > 1
      record.errors.add :base, "Only one value should be supplied, in either text, decimal or option_id format."
    end
  end

end
