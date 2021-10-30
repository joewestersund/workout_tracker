# == Schema Information
#
# Table name: additional_data_types
#
#  id              :bigint           not null, primary key
#  data_type_name  :string
#  order_in_list   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#  workout_type_id :bigint
#
# Indexes
#
#  index_additional_data_types_on_user_id          (user_id)
#  index_additional_data_types_on_workout_type_id  (workout_type_id)
#  index_adt_on_user_and_workout_type_and_order    (user_id,workout_type_id,order_in_list)
#
class AdditionalDataType < ApplicationRecord
  belongs_to :user
  belongs_to :workout_type

  has_many :additional_data_type_options, dependent: :destroy
  has_many :additional_data_type_values, dependent: :destroy

end
