# == Schema Information
#
# Table name: routes
#
#  id              :bigint           not null, primary key
#  active          :boolean
#  description     :text
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
class Route < ApplicationRecord
  after_initialize :set_defaults, unless: :persisted?

  belongs_to :user
  belongs_to :workout_type

  has_many :workout_routes, dependent: :destroy
  has_many :default_data_points, dependent: :destroy

  validates :user_id, presence: true
  validates :workout_type_id, presence: true
  validates :name, presence: true, length: { maximum: 50}, uniqueness: {scope: [:user_id, :workout_type_id] }
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: [:user_id, :workout_type_id] }

  def set_defaults
    self.active = true
  end

end
