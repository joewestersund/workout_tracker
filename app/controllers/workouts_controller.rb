class WorkoutsController < ApplicationController
  before_action :signed_in_user
  before_action :set_workout, only: %i[ show edit update destroy ]
  before_action :get_workout_types, only: [:new, :edit]
  # GET /workouts or /workouts.json

  def index
    #w = current_user.workouts.order(workout_date: :desc)
    @workouts = current_user.workouts.order(workout_date: :desc, created_at: :desc).page(params[:page]).per(10)
  end

  # GET /workouts/1 or /workouts/1.json
  def show
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
      @workout.workout_type = current_user.workout_types.order(:order_in_list).first
    end

    @routes = @workout.workout_type.routes.where(active: true).order(:order_in_list)

    apply_defaults(@workout)
    get_json(@workout)

    #workout_route_templates = get_templates(@workout.workout_type)
    #@workout_route_json = get_json(@workout.workout_type, @workout.workout_routes, workout_route_templates)

  end

  # GET /workouts/1/edit
  def edit
    apply_defaults(@workout)
    get_json(@workout)
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
        get_json(@workout)
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
        get_json(@workout)
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
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def save_workout_routes(workout)
      # have to save the objects along the way, because sub-objects need to know the id of their parent
      workout.save!

      # user had the chance to view/edit only workout_routes for routes that are active.
      # see which wr are currently in workout. We'll delete these wr at the end
      # unless they appear in the new wr received from the user.
      workout_routes_to_delete = workout.workout_routes.map{ |wr| wr.route.active? ? wr : nil }.compact

      show_debug_info("workout_routes_to_delete", workout_routes_to_delete,)

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
              show_debug_info("found workout_route_id #{workout_route_id}")
              wr = workout.workout_routes.where(id: workout_route_id).first
              show_debug_info("got workout_route #{wr}")
              if wr.present? && wr.route == route
                # remove wr from the array.
                workout_routes_to_delete.delete(wr)
                show_debug_info("removing workout_route for route #{wr.route.name}")
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
                    show_debug_info("editing existing data point #{dp.to_s}")
                  else
                    # we didn't find an existing data point, so make a new one
                    dp = wr.data_points.build(user: current_user, data_type: dt)
                  end
                  if dt.is_dropdown?
                    opt = dt.dropdown_options.find(dt_params[:option_id])
                    if opt.present?
                      dp.dropdown_option = opt
                      dp.save!
                    end
                  elsif dt.is_text?
                    val = dt_params[:value]
                    if val.present?
                      dp.text_value = val
                      dp.save!
                    end
                  else
                    val = dt_params[:value]
                    if val.present?
                      dp.decimal_value = val
                      dp.save!
                    end
                  end
                end
              end
            end
            show_debug_info("deleting data points #{data_points_to_delete.each {|dp| dp.to_s }}")
            data_points_to_delete.each {|dp| dp.destroy }
          end
        end
      end
      show_debug_info("deleting workout_routes #{workout_routes_to_delete.each {|wr| wr.route.name }}")
      workout_routes_to_delete.each {|wr| wr.destroy }
    end

    def apply_defaults(workout)
      workout.workout_routes.each do |wr|
        wr.apply_defaults
      end
    end

    def get_templates(workout)
      workout_route_templates = []
      workout.workout_type.routes.where(active: true).order(:order_in_list).each do |route|
        workout_route_templates << WorkoutRoute.create_from_defaults(workout, route)
      end
      workout_route_templates
    end

    def get_json(workout)
      workout_route_templates = get_templates(workout)
      active_workout_routes = []
      workout.workout_routes.each do |wr|
        active_workout_routes << wr if wr.route.active?
      end

      @workout_route_json = Jbuilder.new do |json|
        json.workout_routes active_workout_routes.map { |wr| wr.to_builder.attributes! }
        json.workout_route_templates workout_route_templates.map { |wr| wr.to_builder.attributes! }
        json.data_types workout.workout_type.data_types.where(active: true).map { |dt| dt.to_builder.attributes! }
      end.target!.html_safe
    end

    def show_debug_info(str, var=nil)
      puts "**************"
      if var.present?
        puts "#{str} = #{var}"
      else
        puts str
      end
      puts "**************"
    end
end
