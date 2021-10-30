# == Schema Information
#
# Table name: additional_data_type_values
#
#  id                             :bigint           not null, primary key
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  additional_data_type_id        :bigint
#  additional_data_type_option_id :bigint
#  user_id                        :bigint
#  workout_id                     :bigint
#
# Indexes
#
#  index_additional_data_type_values_on_user_id     (user_id)
#  index_additional_data_type_values_on_workout_id  (workout_id)
#  index_adtv_on_adt                                (additional_data_type_id)
#  index_adtv_on_adto                               (additional_data_type_option_id)
#
class AdditionalDataTypeValue < ApplicationRecord
  belongs_to :user
  belongs_to :workout
  belongs_to :additional_data_type
  belongs_to :additional_data_type_option
end
