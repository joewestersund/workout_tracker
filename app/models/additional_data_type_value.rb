# == Schema Information
#
# Table name: additional_data_type_values
#
#  id                             :bigint           not null, primary key
#  decimal_value                  :decimal(, )
#  text_value                     :text
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  additional_data_type_id        :bigint
#  additional_data_type_option_id :bigint
#  user_id                        :bigint
#  workout_route_id               :bigint
#
# Indexes
#
#  index_additional_data_type_values_on_user_id           (user_id)
#  index_additional_data_type_values_on_workout_route_id  (workout_route_id)
#  index_adtv_on_adt                                      (additional_data_type_id)
#  index_adtv_on_adto                                     (additional_data_type_option_id)
#
class AdditionalDataTypeValue < ApplicationRecord
  belongs_to :user
  belongs_to :workout_route
  belongs_to :additional_data_type
  belongs_to :additional_data_type_option

  validates :user_id, presence: true
  validates :workout_id, presence: true
  validates :additional_data_type_id, presence: true

  validate :one_of_three_is_present

  def one_of_three_is_present
    count = 0
    count += 1 if additional_data_type_option_id.present?
    count += 1 if decimal_value.present?
    count += 1 if text_value.present?
    if count == 0
      record.errors.add :base, "No text, decimal or option_id value was supplied."
    elsif count > 1
      record.errors.add :base, "Only one value should be supplied, in either text, decimal or option_id format."
    end
  end

end
