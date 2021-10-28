class WorkoutRoutesController < ApplicationController
  before_action :set_workout_route, only: %i[ show edit update destroy ]

  # GET /workout_routes or /workout_routes.json
  def index
    @workout_routes = WorkoutRoute.all
  end

  # GET /workout_routes/1 or /workout_routes/1.json
  def show
  end

  # GET /workout_routes/new
  def new
    @workout_route = WorkoutRoute.new
  end

  # GET /workout_routes/1/edit
  def edit
  end

  # POST /workout_routes or /workout_routes.json
  def create
    @workout_route = WorkoutRoute.new(workout_route_params)

    respond_to do |format|
      if @workout_route.save
        format.html { redirect_to @workout_route, notice: "Workout route was successfully created." }
        format.json { render :show, status: :created, location: @workout_route }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @workout_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workout_routes/1 or /workout_routes/1.json
  def update
    respond_to do |format|
      if @workout_route.update(workout_route_params)
        format.html { redirect_to @workout_route, notice: "Workout route was successfully updated." }
        format.json { render :show, status: :ok, location: @workout_route }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @workout_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workout_routes/1 or /workout_routes/1.json
  def destroy
    @workout_route.destroy
    respond_to do |format|
      format.html { redirect_to workout_routes_url, notice: "Workout route was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workout_route
      @workout_route = WorkoutRoute.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def workout_route_params
      params.require(:workout_route).permit(:belongs_to, :belongs_to, :belongs_to, :repetitions, :distance, :pace, :duration, :heart_rate, :description)
    end
end
