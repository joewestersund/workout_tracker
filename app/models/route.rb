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
#  index_routes_on_user_id                    (user_id)
#  index_routes_on_user_id_and_order_in_list  (user_id,order_in_list)
#  index_routes_on_workout_type_id            (workout_type_id)
#
class Route < ApplicationRecord

  has_many :workout_routes, dependent: :restrict_with_exception

  belongs_to :user
  belongs_to :workout_type

  validates :user_id, presence: true
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: :user_id }
end
