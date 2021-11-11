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
class DropdownOption < ApplicationRecord
  belongs_to :user
  belongs_to :data_type

  has_many :data_points, dependent: :restrict_with_exception

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50}, uniqueness: {scope: [:user_id, :data_type_id] }
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: [:user_id, :data_type_id] }


end
