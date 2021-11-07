# == Schema Information
#
# Table name: additional_data_type_options
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  order_in_list           :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  additional_data_type_id :bigint
#  user_id                 :bigint
#
# Indexes
#
#  index_additional_data_type_options_on_additional_data_type_id  (additional_data_type_id)
#  index_additional_data_type_options_on_user_id                  (user_id)
#  index_adto_on_user_and_adt_and_order                           (user_id,additional_data_type_id,order_in_list)
#
class AdditionalDataTypeOption < ApplicationRecord
  belongs_to :user
  belongs_to :additional_data_type

  has_many :additional_data_type_values, dependent: :restrict_with_exception

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50}, uniqueness: {scope: [:user_id, :additional_data_type_id] }
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: [:user_id, :additional_data_type_id] }


end
