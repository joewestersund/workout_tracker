class RoutesController < ApplicationController
  before_action :signed_in_user
  before_action :set_route, only: %i[ show edit update destroy ]

  # GET /routes or /routes.json
  def index
    @routes = current_user.routes.order(:order_in_list)
  end

  # GET /routes/1 or /routes/1.json
  def show
  end

  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
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
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = current_user.routes.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def route_params
      params.require(:route).permit(:belongs_to, :belongs_to, :name, :distance, :order_in_list)
    end

    def move(up)
      move_in_list(current_user.routes, routes_path, params[:id], up)
    end
end
