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

    @workout_route_json = get_json(@workout.workout_type, @workout.workout_routes, workout_route_templates)

  end

  # GET /workouts/1/edit
  def edit
    apply_defaults(@workout)
    workout_route_templates = get_templates(@workout.workout_type)

    @workout_route_json = get_json(@workout.workout_type, @workout.workout_routes, workout_route_templates)
  end

  # POST /workouts or /workouts.json
  def create
    @workout = Workout.new(workout_params)
    @workout.user = current_user

    get_workout_routes(@workout)

    puts "workout routes ******"
    puts @workout.workout_routes.inspect
    puts "***************"

    ActiveRecord::Base.transaction do
      begin
        @workout.workout_routes.each do |wr|
          wr.data_points.each do |dp|
            if dp.save
              puts "saved dp #{dp.data_type.name}"
            else
              puts "couldn't save dp #{dp.data_type.name}: #{dp.errors.full_messages}"
            end
          end
          if wr.save
            puts "saved wr #{wr.route.name}"
          else
            puts "couldn't save wr #{wr.route.name}: #{wr.errors.full_messages}"
          end
        end
        if @workout.save
          puts "saved workout"
        else
          puts "couldnt save workout: #{@workout.errors.full_messages}"
        end
        respond_to do |format|
          format.html { redirect_to workouts_path, notice: "Workout was successfully created." }
          format.json { render :show, status: :created, location: @workout }
        end
      # rescue
      #   get_workout_types
      #   format.html { render :new, status: :unprocessable_entity }
      #   format.json { render json: @workout.errors, status: :unprocessable_entity }
      # end
    end
  end


    # respond_to do |format|
    #   if @workout.save
    #     format.html { redirect_to workouts_path, notice: "Workout was successfully created." }
    #     format.json { render :show, status: :created, location: @workout }
    #   else
    #     get_workout_types
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @workout.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    respond_to do |format|
      if @workout.update(workout_params)
        format.html { redirect_to workouts_path, notice: "Workout was successfully updated." }
        format.json { render :show, status: :ok, location: @workout }
      else
        get_workout_types
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

    def get_workout_routes(workout)
      route_count = params.require(:workout).permit(:route_count)[:route_count].to_i
      #workout_routes = []
      1.upto(route_count) do |num|
        workout_params = params.require(:workout)

        route_params = workout_params["route#{num}"]
        if route_params.present?
          workout_type = workout.workout_type
          route = workout_type.routes.find(route_params[:route_id])
          if route.present?
            wr = workout.workout_routes.build(user: current_user, route: route)
            wr.repetitions = route_params[:repetitions]
            workout_type.data_types.each do |dt|
              dt_params = route_params["data_type#{dt.id}"]
              if dt_params.present?
                dp = wr.data_points.build(user: current_user, data_type: dt)
                if dt.is_dropdown?
                  opt = dt.dropdown_options.find(dt_params[:option_id])
                  dp.dropdown_option = opt
                elsif dt.is_text?
                  val = dt_params[:value]
                  dp.text_value = val
                else
                  val = dt_params[:value]
                  dp.decimal_value = val
                end
              end
            end
          end
        end
      end
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

    def get_json(workout_type, workout_routes, workout_route_templates)
      Jbuilder.new do |json|
        json.workout_routes workout_routes.collect { |wr| wr.to_builder.attributes! }
        json.workout_route_templates workout_route_templates.collect { |wr| wr.to_builder.attributes! }
        json.data_types workout_type.data_types.collect { |dt| dt.to_builder.attributes! }
      end.target!.html_safe
    end
end
