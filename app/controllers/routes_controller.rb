class RoutesController < ApplicationController
  before_action :signed_in_user
  before_action :set_workout_type, except: [ :index, :index_first]
  before_action :set_route, only: %i[ show edit update destroy move_up move_down]

  # GET /routes or /routes.json
  def index_first
    @workout_types = current_user.workout_types.order(:order_in_list)
    @workout_type = @workout_types.first
    @routes = @workout_type.routes.order(:order_in_list)
    render :index
  end

  def index
    @workout_types = current_user.workout_types.order(:order_in_list)

    # for index only, get the fist workout type if the user didn't specify one
    if params[:workout_type_id].present?
      set_workout_type
    else
      @workout_type = @workout_types.first
    end
    @routes = @workout_type.routes.order(:order_in_list)
  end

  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
    @route = @workout_type.routes.find(params[:id])
  end

  # POST /routes or /routes.json
  def create
    @route = Route.new(route_params)
    @route.user = current_user
    @route.type.order_in_list = next_order_in_list(current_user.routes)

    respond_to do |format|
      if @route.save
        format.html { redirect_to routes_path, notice: "Route was successfully created." }
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
        format.html { redirect_to routes_path, notice: "Route was successfully updated." }
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
    @route.destroy
    respond_to do |format|
      format.html { redirect_to routes_url, notice: "Route was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_workout_type
      @workout_type = current_user.workout_types.find(params[:workout_type_id])
    end

    def set_route
      @route = nil
      @route = @workout_type.routes.find(params[:id]) if @workout_type.present?
    end

    # Only allow a list of trusted parameters through.
    def route_params
      params.require(:route).permit(:belongs_to, :belongs_to, :name, :distance, :order_in_list)
    end

    def move(up)
      move_in_list(current_user.routes, routes_path, params[:id], up)
    end
end
