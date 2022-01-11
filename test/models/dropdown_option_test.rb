# == Schema Information
#
# Table name: dropdown_options
#
#  id            :bigint           not null, primary key
#  name          :string
#  order_in_list :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  data_type_id  :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_adto_on_user_and_adt_and_order    (user_id,data_type_id,order_in_list)
#  index_dropdown_options_on_data_type_id  (data_type_id)
#  index_dropdown_options_on_user_id       (user_id)
#
require "test_helper"

class WorkoutTypeDropdownOptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
