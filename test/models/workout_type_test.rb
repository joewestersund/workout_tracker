# == Schema Information
#
# Table name: workout_types
#
#  id            :bigint           not null, primary key
#  name          :string
#  order_in_list :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint
#
# Indexes
#
#  index_workout_types_on_user_id                    (user_id)
#  index_workout_types_on_user_id_and_order_in_list  (user_id,order_in_list)
#
require "test_helper"

class WorkoutTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
