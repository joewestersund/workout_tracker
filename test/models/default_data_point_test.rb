# == Schema Information
#
# Table name: default_data_points
#
#  id                 :bigint           not null, primary key
#  decimal_value      :decimal(, )
#  text_value         :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  data_type_id       :bigint
#  dropdown_option_id :bigint
#  route_id           :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_ddp_on_do                        (dropdown_option_id)
#  index_ddp_on_dt                        (data_type_id)
#  index_default_data_points_on_route_id  (route_id)
#  index_default_data_points_on_user_id   (user_id)
#
require "test_helper"

class DefaultDataPointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
