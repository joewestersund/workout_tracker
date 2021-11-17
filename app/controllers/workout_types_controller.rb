class WorkoutTypesController < ApplicationController
  before_action :signed_in_user
  before_action :set_workout_type, only: %i[ edit update destroy default_workout_routes]

  # GET /workout_types or /workout_types.json
  def index
    @workout_types = current_user.workout_types.order(:order_in_list)
  end

  # GET /workout_types/1/default_workout_routes.json
  def default_workout_routes
    @workout_routes = []
    @workout_type.routes.order(:order_in_list).each do |route|
      @workout_routes << WorkoutRoute.create_from_defaults(route)
    end
  end

  # GET /workout_types/new
  def new
    @workout_type = WorkoutType.new
  end

  # GET /workout_types/1/edit
  def edit
  end

  # POST /workout_types or /workout_types.json
  def create
    @workout_type = WorkoutType.new(workout_type_params)
    @workout_type.user = current_user
    @workout_type.order_in_list = next_order_in_list(current_user.workout_types)

    respond_to do |format|
      if @workout_type.save
        format.html { redirect_to workout_types_path, notice: "Workout type was successfully created." }
        format.json { render :index, status: :created, location: @workout_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @workout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workout_types/1 or /workout_types/1.json
  def update
    respond_to do |format|
      if @workout_type.update(workout_type_params)
        format.html { redirect_to workout_types_path, notice: "Workout type was successfully updated." }
        format.json { render :index, status: :ok, location: @workout_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @workout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def move_up
    move(true)
  end

  def move_down
    move(false)
  end

  # DELETE /workout_types/1 or /workout_types/1.json
  def destroy
    current_workout_type_oil = @workout_type.order_in_list
    @workout_type.destroy
    handle_delete_of_order_in_list(current_user.workout_types,current_workout_type_oil)
    respond_to do |format|
      format.html { redirect_to workout_types_url, notice: "Workout type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workout_type
      @workout_type = current_user.workout_types.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def workout_type_params
      params.require(:workout_type).permit(:name, :order_in_list)
    end

    def move(up)
      move_in_list(current_user.workout_types, workout_types_path, params[:id], up)
    end
end
