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
class WorkoutType < ApplicationRecord
  belongs_to :user

  has_many :routes, dependent: :destroy
  has_many :data_types, dependent: :destroy
  has_many :workouts, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50}, uniqueness: {scope: :user_id }
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: :user_id }

  def to_builder

    Jbuilder.new do |json|
      json.id self.id
      json.name self.name
      json.routes self.routes.order(:order_in_list) do |r|
        json.id r.id
        json.name r.name
      end
      json.data_types self.data_types.order(:order_in_list).map { |dt| dt.to_builder.attributes! }
    end
  end

end
