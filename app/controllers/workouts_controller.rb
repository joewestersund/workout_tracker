class WorkoutsController < ApplicationController
  before_action :signed_in_user
  before_action :set_workout, only: %i[ show edit update destroy ]
  before_action :get_workout_types, only: [:new, :edit]
  # GET /workouts or /workouts.json

  def index
    conditions = get_conditions

    w = current_user.workouts.where("id IN (?)", current_user.workouts.left_outer_joins(workout_routes: :data_points).where(conditions).select(:id))
    w = w.order(workout_date: :desc, created_at: :desc)

    respond_to do |format|
      format.html {
        @workout_filter_json = get_workout_filter_json()
        @filtered = !conditions[1].empty?
        @workouts = w.page(params[:page]).per(20)
      }
      format.xlsx {
        @workout_types = current_user.workout_types.order(:order_in_list)
        @workouts = w
        response.headers['Content-Disposition'] = 'attachment; filename="workouts.xlsx"'
      }
    end

  end

  # GET /workouts/new
  def new
    @workout = Workout.new
    @workout.workout_date = DateTime.now.in_time_zone(current_user.time_zone)

    wt_id = params[:workout_type_id]
    wt = current_user.workout_types.find(wt_id) if wt_id.present?
    if wt.present?
      @workout.workout_type = wt
    else
      @workout.workout_type = @workout_types.first
    end

    apply_defaults(@workout)
    get_workout_form_json(@workout)

  end

  # GET /workouts/1/edit
  def edit
    apply_defaults(@workout)
    get_workout_form_json(@workout)
  end

  # POST /workouts or /workouts.json
  def create
    @workout = Workout.new(workout_params)
    @workout.user = current_user

    ActiveRecord::Base.transaction do
      begin
        save_workout_routes(@workout)
        respond_to do |format|
          format.html { redirect_to workouts_path, notice: "Workout was successfully created." }
          format.json { render :show, status: :created, location: @workout }
        end
      rescue
        get_workout_types
        apply_defaults(@workout)
        get_workout_form_json(@workout)
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @workout.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    ActiveRecord::Base.transaction do
      begin
        @workout.update!(workout_params)
        save_workout_routes(@workout)
        respond_to do |format|
          format.html { redirect_to workouts_path, notice: "Workout was successfully updated." }
          format.json { render :show, status: :created, location: @workout }
        end
      rescue
        get_workout_types
        apply_defaults(@workout)
        get_workout_form_json(@workout)
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @workout.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /workouts/1 or /workouts/1.json
  def destroy
    @workout.destroy
    respond_to do |format|
      format.html { redirect_to workouts_url, notice: "Workout was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout = current_user.workouts.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def workout_params
      params.require(:workout).permit(:workout_date, :workout_type_id)
    end

    def get_workout_types
      # only include workout types that have one or more routes.
      workout_types = current_user.workout_types.order(:order_in_list)
      @workout_types = []
      workout_types.each do |wt|
        @workout_types << wt if wt.routes.count > 0
      end
    end

    def save_workout_routes(workout)
      # have to save the objects along the way, because sub-objects need to know the id of their parent
      workout.save!

      # user had the chance to view/edit only workout_routes for routes that are active.
      # see which wr are currently in workout. We'll delete these wr at the end
      # unless they appear in the new wr received from the user.
      workout_routes_to_delete = workout.workout_routes.map{ |wr| wr.route.active? ? wr : nil }.compact

      route_count = params.require(:workout).permit(:route_count)[:route_count].to_i
      1.upto(route_count) do |num|
        workout_params = params.require(:workout)

        route_params = workout_params["route#{num}"]
        if route_params.present?
          workout_type = workout.workout_type
          route = workout_type.routes.find(route_params[:route_id])
          if route.present?

            workout_route_id = route_params[:workout_route_id]
            if workout_route_id.present?
              # edit existing workout_route, to preserve values of any inactive data_types
              wr = workout.workout_routes.where(id: workout_route_id).first
              if wr.present? && wr.route == route
                # remove wr from the array.
                workout_routes_to_delete.delete(wr)
              else
                # create a new workout_route
                wr = workout.workout_routes.build(user: current_user, route: route)
              end
            else
              # create a new workout_route
              wr = workout.workout_routes.build(user: current_user, route: route)
            end

            wr.repetitions = route_params[:repetitions]
            wr.save!

            # user had the chance to view/edit only data_points for data_types that are active.
            # see which dp are currently in wr. We'll delete these dp at the end
            # unless they appear in the new dp received from the user.
            data_points_to_delete = wr.data_points.map{ |dp| dp.data_type.active? ? dp : nil }.compact

            workout_type.data_types.each do |dt|
              dt_params = route_params["data_type#{dt.id}"]
              if dt_params.present?
                if dt_params[:value].present? or dt_params[:option_id].present?
                  # look for an existing data point
                  dp = wr.data_points.find_by(data_type: dt)
                  if dp.present?
                    # remove dp from the array.
                    data_points_to_delete.delete(dp)
                  else
                    # we didn't find an existing data point, so make a new one
                    dp = wr.data_points.build(user: current_user, data_type: dt)
                  end
                  if dt.is_dropdown?
                    opt = dt.dropdown_options.find(dt_params[:option_id])
                    if opt.present?
                      dp.set_value(opt.id)
                      dp.save!
                    end
                  else
                    val = dt_params[:value]
                    if val.present?
                      dp.set_value(val)
                      dp.save!
                    end
                  end
                end
              end
            end
            data_points_to_delete.each {|dp| dp.destroy }
          end
        end
      end
      workout_routes_to_delete.each {|wr| wr.destroy }
    end

    def apply_defaults(workout)
      workout.workout_routes.each do |wr|
        wr.apply_defaults
      end
    end

    def get_templates(workout)
      workout_route_templates = []

      inactive_routes_in_current_workout = workout.workout_routes.map{ |wr| wr.route.active? ? nil : wr.route.id}.compact
      # start with the active routes
      # and add any inactive routes that are in the current workout
      routes = workout.workout_type.routes.where(active: true).or(workout.workout_type.routes.where(id: inactive_routes_in_current_workout))

      routes.order(:order_in_list).each do |route|
        workout_route_templates << WorkoutRoute.create_from_defaults(workout, route)
      end
      workout_route_templates
    end

    def get_workout_filter_json
      @workout_filter_json = Jbuilder.new do |json|
        json.workout_types current_user.workout_types.map { |wt| wt.to_builder.attributes! }
      end.target!.html_safe
    end

    def get_workout_form_json(workout)

      workout_route_templates = get_templates(workout)

      @workout_form_json = Jbuilder.new do |json|
        json.workout_routes workout.workout_routes.map { |wr| wr.to_builder.attributes! }
        json.workout_route_templates workout_route_templates.map { |wr| wr.to_builder.attributes! }
        json.data_types workout.workout_type.data_types.where(active: true).map { |dt| dt.to_builder.attributes! }
      end.target!.html_safe
    end

    def get_conditions

      search_terms = Workout.new(search_params)

      conditions = {}
      conditions_string = []

      conditions[:start_date] = params[:start_date] if params[:start_date].present?
      conditions_string << "workout_date >= :start_date" if params[:start_date].present?

      conditions[:end_date] = params[:end_date] if params[:end_date].present?
      conditions_string << "workout_date <= :end_date" if params[:end_date].present?

      conditions[:year] = search_terms.year if search_terms.year.present?
      conditions_string << "year = :year" if search_terms.year.present?

      conditions[:month] = search_terms.month if search_terms.month.present?
      conditions_string << "month = :month" if search_terms.month.present?

      conditions[:day] = search_terms.day if search_terms.day.present?
      conditions_string << "day = :day" if search_terms.day.present?

      conditions[:workout_type_id] = search_terms.workout_type_id if search_terms.workout_type_id.present?
      conditions_string << "workout_type_id = :workout_type_id" if search_terms.workout_type_id.present?

      conditions[:route_id] = params[:route_id] if params[:route_id].present?
      conditions_string << "workout_routes.route_id = :route_id" if params[:route_id].present?

      if params[:data_type_id].present? && params[:operator].present?
        dt = current_user.data_types.find(params[:data_type_id])
        if dt.present?
          if dt.is_dropdown? && params[:dropdown_option_id].present?
            conditions[:dropdown_option_id] = params[:dropdown_option_id]
            conditions_string << "data_points.dropdown_option_id = :dropdown_option_id"
          elsif params[:comparison_value].present?
            val = params[:comparison_value]
            op = params[:operator]
            if dt.is_text?
              if op == 'LIKE'
                conditions[:text_value] = "%#{val}%"
                conditions_string << "data_points.text_value ILIKE :text_value"
                "comments.summary ILIKE :summary"
              else
                conditions[:text_value] = val
                conditions_string << "data_points.text_value = :text_value"
              end
            elsif dt.is_numeric? || dt.is_hours_minutes? || dt.is_minutes_seconds?
              allowed_operators = %w[ < <= = >= > != <> ]
              if allowed_operators.include?(op)
                conditions[:decimal_value] = dt.convert_to_number(val)
                conditions_string << "data_points.decimal_value #{op} :decimal_value"
              end
            else
              raise "DataType.field_type was not recognized"
            end
          end
        end
      end

      return [conditions_string.join(" AND "), conditions]
    end

    def search_params
      params.permit(:year, :month, :day, :workout_type_id)
    end

end
