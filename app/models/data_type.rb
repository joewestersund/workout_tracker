# == Schema Information
#
# Table name: data_types
#
#  id              :bigint           not null, primary key
#  description     :text
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
#  index_adt_on_user_and_workout_type_and_order  (user_id,workout_type_id,order_in_list)
#  index_data_types_on_user_id                   (user_id)
#  index_data_types_on_workout_type_id           (workout_type_id)
#
class DataType < ApplicationRecord
  belongs_to :user
  belongs_to :workout_type

  has_many :dropdown_options, dependent: :destroy
  has_many :data_points, dependent: :destroy
  has_many :default_data_points, dependent: :destroy

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

  def is_dropdown?
    field_type == FIELD_TYPES[:dropdown]
  end

  def is_text?
    field_type == FIELD_TYPES[:text]
  end

  def is_numeric?
    field_type == FIELD_TYPES[:numeric]
  end

  def to_builder
    Jbuilder.new do |json|
      json.id self.id
      json.name self.name
      json.description self.description
      json.is_dropdown self.is_dropdown?
      json.is_numeric self.is_numeric?
      if self.is_dropdown?
        json.options self.dropdown_options.order(:order_in_list) do |opt|
          json.option_id opt.id
          json.option_name opt.name
        end
      end
    end
  end

end
