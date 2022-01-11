# == Schema Information
#
# Table name: data_types
#
#  id              :bigint           not null, primary key
#  active          :boolean
#  description     :text
#  field_type      :string
#  name            :string
#  order_in_list   :integer
#  units           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#  workout_type_id :bigint
#
# Indexes
#
#  index_adt_on_user_and_workout_type_and_order  (user_id,workout_type_id,order_in_list)
#  index_data_types_on_user_id                   (user_id)
#  index_data_types_on_workout_type_id           (workout_type_id)
#
require "test_helper"

class WorkoutTypeDataTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
