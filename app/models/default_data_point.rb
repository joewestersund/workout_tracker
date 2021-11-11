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
class DefaultDataPoint < ApplicationRecord
  belongs_to :user
  belongs_to :route
  belongs_to :data_type
  belongs_to :dropdown_option, optional: true

  validates :user_id, presence: true
  validates :route_id, presence: true
  validates :data_type_id, presence: true

  validate :one_of_three_is_present

  def one_of_three_is_present
    count = 0
    count += 1 if dropdown_option_id.present?
    count += 1 if decimal_value.present?
    count += 1 if text_value.present?
    if count == 0
      record.errors.add :base, "No text, decimal or dropdown option id value was supplied."
    elsif count > 1
      record.errors.add :base, "Only one value should be supplied, in either text, decimal or dropdown option id format."
    end
  end

  def to_s
    if dropdown_option_id.present?
      val = self.dropdown_option.name
    elsif text_value.present?
      val = text_value
    else
      val = decimal_value
    end
    "#{self.data_type.name}: #{val}"
  end
end
