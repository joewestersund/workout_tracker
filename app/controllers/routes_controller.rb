class RoutesController < ApplicationController
  before_action :signed_in_user
  before_action :get_workout_types
  before_action :set_workout_type, except: %i[ default_index edit update destroy move_up move_down]
  before_action :set_route_and_workout_type, only: %i[ edit update destroy move_up move_down]

  # GET /routes or /routes.json
  def default_index
    @workout_type = @workout_types.first
    @routes = @workout_type.routes.order(:order_in_list).page(params[:page]).per(10)
    @data_types = @workout_type.data_types.where(active: true).order(:order_in_list)
    render :index
  end

  def index
    @routes = @workout_type.routes.order(:order_in_list).page(params[:page]).per(10)
    @data_types = @workout_type.data_types.where(active: true).order(:order_in_list)
  end

  # GET /routes/new
  def new
    @route = Route.new
    @route.workout_type = @workout_type
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes or /routes.json
  def create
    @route = Route.new(route_params)
    @route.user = current_user
    @route.workout_type = current_user.workout_types.find(@workout_type.id)
    @route.order_in_list = next_order_in_list(@workout_type.routes)

    respond_to do |format|
      if @route.save
        format.html { redirect_to workout_type_routes_path(@workout_type), notice: "Route was successfully created." }
        format.json { render :index, status: :created, location: @route }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1 or /routes/1.json
  def update
    respond_to do |format|
      if @route.update(route_params)
        format.html { redirect_to workout_type_routes_path(@workout_type), notice: "Route was successfully updated." }
        format.json { render :index, status: :ok, location: @route }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  def move_up
    move(true)
  end

  def move_down
    move(false)
  end

  # DELETE /routes/1 or /routes/1.json
  def destroy
    # delete any workouts that only consisted of this route.
    current_user.workout_routes.where(route: @route).each do |wr|
      wr.workout.destroy if wr.workout.workout_routes.count == 1
    end

    deleted_OIL = @route.order_in_list
    @route.destroy
    handle_delete_of_order_in_list(@workout_type.routes,deleted_OIL)
    respond_to do |format|
      format.html { redirect_to workout_type_routes_path(@workout_type), notice: "Route was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    def get_workout_types
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def set_workout_type
      @workout_type = current_user.workout_types.find(params[:workout_type_id])
    end

    def set_route_and_workout_type
      @route = current_user.routes.find(params[:id])
      @workout_type = @route.workout_type
    end

    # Only allow a list of trusted parameters through.
    def route_params
      params.require(:route).permit(:workout_type_id, :name, :distance, :description, :active)
    end

    def move(up)
      route = current_user.routes.find(params[:id])
      workout_type = route.workout_type
      move_in_list(workout_type.routes, workout_type_routes_path(workout_type), route, up)
    end
end
