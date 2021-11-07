# == Schema Information
#
# Table name: routes
#
#  id              :bigint           not null, primary key
#  distance        :decimal(, )
#  name            :string
#  order_in_list   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#  workout_type_id :bigint
#
# Indexes
#
#  index_routes_on_user_id                                        (user_id)
#  index_routes_on_user_id_and_workout_type_id_and_order_in_list  (user_id,workout_type_id,order_in_list)
#  index_routes_on_workout_type_id                                (workout_type_id)
#
require "test_helper"

class RouteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
