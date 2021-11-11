module UsersHelper

  def set_up_user_defaults(user)
    ['run', 'boulder', 'toprope', 'lead climb'].each_with_index do |wt, index|
      user.workout_types.create(name: wt, order_in_list: index + 1)
    end
    wt = user.workout_types.find(name: 'run')
    numeric_field_type = DataType.field_types_hash[:numeric]
    wt.data_types.create(name: 'hr', field_type: numeric_field_type, unit: "bpm")

  end
end
