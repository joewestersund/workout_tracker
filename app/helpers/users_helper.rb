module UsersHelper

  def set_up_user_defaults(user)
    ['run', 'boulder', 'toprope', 'lead climb'].each_with_index do |wt, index|
      user.workout_types.create(name: wt, order_in_list: index + 1)
    end
    wt = user.workout_types.find(name: 'run')
    numeric_field_type = DataType.field_types_hash[:numeric]
    wt.data_types.create(name: 'hr', field_type: numeric_field_type, unit: "bpm")

  end

  def create_user_defaults(user)
    wt = user.workout_types.create!(name: "running", order_in_list: 1)
    wt.data_types.create!(name: "distance", unit: "miles", field_type: DataType.field_types_hash[:numeric], order_in_list: 1)
    wt.data_types.create!(name: "hr", unit: "bpm", field_type: DataType.field_types_hash[:numeric], order_in_list: 2)
    dt = wt.data_types.create!(name: "surface", field_type: DataType.field_types_hash[:dropdown], order_in_list: 3)
    dt.dropdown_options.create!(name: "road", order_in_list: 1)
    dt.dropdown_options.create!(name: "trail", order_in_list: 2)

    wt = user.workout_types.create!(name: "bouldering2", order_in_list: 2)
    dt = wt.data_types.create!(name: "notes", field_type: DataType.field_types_hash[:text], order_in_list: 1)
    wt.routes.create!(name: "V0", order_in_list: 1)
    wt.routes.create!(name: "V1", order_in_list: 2)
    wt.routes.create!(name: "V2", order_in_list: 3)
    wt.routes.create!(name: "V3", order_in_list: 4)
    wt.routes.create!(name: "V4", order_in_list: 5)

    wt = user.workout_types.create!(name: "climbing", order_in_list: 3)
    dt = wt.data_types.create!(name: "grade", field_type: DataType.field_types_hash[:dropdown], order_in_list: 1)
    dt.dropdown_options.create!(name: "5.5", order_in_list: 1)
    dt.dropdown_options.create!(name: "5.6", order_in_list: 2)
    dt.dropdown_options.create!(name: "5.7", order_in_list: 3)
    dt.dropdown_options.create!(name: "5.8", order_in_list: 4)
    dt.dropdown_options.create!(name: "5.9", order_in_list: 5)
    dt.dropdown_options.create!(name: "5.10-", order_in_list: 6)
    dt.dropdown_options.create!(name: "5.10", order_in_list: 7)
    dt.dropdown_options.create!(name: "5.10+", order_in_list: 8)
    dt.dropdown_options.create!(name: "5.11-", order_in_list: 9)
    dt.dropdown_options.create!(name: "5.11", order_in_list: 10)
    dt.dropdown_options.create!(name: "5.11+", order_in_list: 11)

    dt = wt.data_types.create!(name: "style", field_type: DataType.field_types_hash[:dropdown], order_in_list: 2)
    dt.dropdown_options.create!(name: "toprope", order_in_list: 1)
    dt.dropdown_options.create!(name: "lead", order_in_list: 2)

    dt = wt.data_types.create!(name: "notes", field_type: DataType.field_types_hash[:text], order_in_list: 3)

  end
end
