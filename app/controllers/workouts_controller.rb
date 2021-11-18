class WorkoutsController < ApplicationController
  before_action :signed_in_user
  before_action :set_workout, only: %i[ show edit update destroy ]
  before_action :get_workout_types, only: [:new, :edit]
  # GET /workouts or /workouts.json
  def index
    @workouts = current_user.workouts.order(workout_date: :desc)
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

    @routes = @workout.workout_type.routes.order(:order_in_list)

    apply_defaults(@workout)
    workout_route_templates = get_templates(@workout.workout_type)

    @workout_route_json = get_json(@workout.workout_routes, workout_route_templates)

  end

  # GET /workouts/1/edit
  def edit
    apply_defaults(@workout)
    workout_route_templates = get_templates(@workout.workout_type)

    @workout_route_json = get_json(@workout.workout_routes, workout_route_templates)
  end

  # POST /workouts or /workouts.json
  def create
    @workout = Workout.new(workout_params)
    @workout.user = current_user

    puts "******"
    puts params
    puts "******"

    respond_to do |format|
      if @workout.save
        format.html { redirect_to workouts_path, notice: "Workout was successfully created." }
        format.json { render :show, status: :created, location: @workout }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    respond_to do |format|
      if @workout.update(workout_params)
        format.html { redirect_to workouts_path, notice: "Workout was successfully updated." }
        format.json { render :show, status: :ok, location: @workout }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
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
      params.require(:workout).permit(:workout_date, :workout_type_id, :user_id)
    end

    def get_workout_types
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def apply_defaults(workout)
      workout.workout_routes.each do |wr|
        wr.apply_defaults
      end
    end

    def get_templates(workout_type)
      workout_route_templates = []
      workout_type.routes.order(:order_in_list).each do |route|
        workout_route_templates << WorkoutRoute.create_from_defaults(route)
      end
      workout_route_templates
    end

    def get_json(workout_routes, workout_route_templates)
      Jbuilder.new do |json|
        json.workout_routes workout_routes.collect { |wr| wr.to_builder.attributes! }
        json.workout_route_templates workout_route_templates.collect { |wr| wr.to_builder.attributes! }
      end.target!.html_safe
    end
end
