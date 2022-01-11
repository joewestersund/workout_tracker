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
require "test_helper"

class WorkoutTypeDataPointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
