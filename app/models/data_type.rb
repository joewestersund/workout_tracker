# == Schema Information
#
# Table name: data_types
#
#  id              :bigint           not null, primary key
#  active          :boolean
#  description     :text
#  field_type      :string
#  name            :string
#  order_in_list   :integer
#  units           :string
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
  after_initialize :set_defaults, unless: :persisted?

  belongs_to :user
  belongs_to :workout_type

  has_many :dropdown_options, dependent: :destroy
  has_many :data_points, dependent: :destroy
  has_many :default_data_points, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50}, uniqueness: {scope: [:user_id, :workout_type_id] }
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: [:user_id, :workout_type_id] }

  validate :field_type_is_valid

  FIELD_TYPES = {
      dropdown: "dropdown list",
      text: "text",
      numeric: "numeric",
      hours_minutes: "hours:minutes",
      minutes_seconds: "minutes:seconds"
  }

  def set_defaults
    self.active = true
  end

  def self.field_types
    FIELD_TYPES.map{ |key, str| str }
  end

  def self.field_types_hash
    FIELD_TYPES
  end

  def input_pattern
    if self.is_hours_minutes? || self.is_minutes_seconds?
      '\d+:[0-5]\d'
    elsif self.is_numeric?
      '[+-]?(\d+|\.\d+|\d+\.\d+|\d+\.)(e[+-]?\d+)?'  # numeric data, with possible scientific notation
    end
  end

  def title_string
    if self.is_hours_minutes?
      "Enter hours and minutes, like 3:59"
    elsif self.is_minutes_seconds?
      "Enter minutes and seconds, like 12:03"
    elsif self.is_numeric?
      "Enter a number, like 12.41 or 12e-10"
    end
  end

  def convert_to_number(str)
    # convert to seconds
    if self.is_numeric?
      str.to_f  # just return the string
    elsif self.is_hours_minutes?
      numbers = str.split(":").map{ |n| n.to_i }
      raise "string #{str} was not recognized as a valid hours:minutes string" if numbers.length != 2
      numbers[0] * 3600 + numbers[1] * 60
    elsif self.is_minutes_seconds?
      numbers = str.split(":").map{ |n| n.to_i }
      raise "string #{str} was not recognized as a valid minutes:seconds string" if numbers.length != 2
      numbers[0] * 60 + numbers[1]
    end
  end

  def convert_from_number(value)
    if value.blank?
      ""
    elsif self.is_hours_minutes?
      hours = (value / 3600).floor
      minutes = ((value - (hours * 3600)) / 60).floor
      "#{hours}:#{"%02d" % minutes}"   # pad minutes with preceding zero if needed
    elsif self.is_minutes_seconds?
      minutes = (value / 60).floor
      seconds = (value - (minutes * 60)).floor
      "#{minutes}:#{"%02d" % seconds}"   # pad minutes with preceding zero if needed
    else
      value
    end
  end

  def field_type_is_valid
    FIELD_TYPES.has_value?(field_type)
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

  def is_hours_minutes?
    field_type == FIELD_TYPES[:hours_minutes]
  end

  def is_minutes_seconds?
    field_type == FIELD_TYPES[:minutes_seconds]
  end

  def summary_function_options
    if self.is_dropdown? || self.is_text?
      %w[ count ]
    else
      %w[sum average min max count]
    end
  end

  def to_builder
    Jbuilder.new do |json|
      json.id self.id
      json.name self.name
      json.description self.description
      json.field_type self.field_type
      json.input_pattern self.input_pattern  # include even if null- will appear as empty string in the json
      json.title_string self.title_string  # include even if null- will appear as empty string in the json
      json.summary_function_options self.summary_function_options
      if self.is_dropdown?
        json.options self.dropdown_options.order(:order_in_list) do |opt|
          json.id opt.id
          json.name opt.name
        end
      end
    end
  end

end
