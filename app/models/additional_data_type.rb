# == Schema Information
#
# Table name: additional_data_types
#
#  id              :bigint           not null, primary key
#  field_type      :string
#  name            :string
#  order_in_list   :integer
#  unit            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#  workout_type_id :bigint
#
# Indexes
#
#  index_additional_data_types_on_user_id          (user_id)
#  index_additional_data_types_on_workout_type_id  (workout_type_id)
#  index_adt_on_user_and_workout_type_and_order    (user_id,workout_type_id,order_in_list)
#
class AdditionalDataType < ApplicationRecord
  belongs_to :user
  belongs_to :workout_type

  has_many :additional_data_type_options, dependent: :destroy
  has_many :additional_data_type_values, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50}, uniqueness: {scope: [:user_id, :workout_type_id] }
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: [:user_id, :workout_type_id] }

  FIELD_TYPES = {
      dropdown: "dropdown list",
      text: "text",
      numeric: "numeric"
  }

  def self.field_types
    FIELD_TYPES.map{ |key, str| str }
  end

  def self.field_types_hash
    FIELD_TYPES
  end

end
