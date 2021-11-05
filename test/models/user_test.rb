# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  activated              :boolean
#  email                  :string
#  name                   :string
#  password_digest        :string
#  password_reset_sent_at :datetime
#  remember_token         :string
#  reset_password_token   :string
#  time_zone              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
