class DefaultDataPointsController < ApplicationController
  before_action :signed_in_user
  before_action :set_default_data_point, only: %i[ edit update destroy ]
  before_action :set_route, except: %i[ edit update destroy]

  # GET /default_data_points or /default_data_points.json
  def index
    @data_types = @route.workout_type.data_types.includes(:default_data_points).order(:order_in_list)
  end

  # GET /default_data_points/new
  def new
    dt_id = params[:data_type_id]
    data_type = @route.workout_type.data_types.find(dt_id) if dt_id.present?
    if data_type.present?
      @default_data_point = current_user.default_data_points.new(route: @route, data_type: data_type)
      @dropdown_options = @default_data_point.data_type.dropdown_options.order(:order_in_list)
    else
      # this is an error
      redirect_to route_default_data_points_path(@route), alert: "Data type ID #{dt_id} was not recognized."
    end
  end

  # GET /default_data_points/1/edit
  def edit
    @dropdown_options = @default_data_point.data_type.dropdown_options.order(:order_in_list)
  end

  # POST /default_data_points or /default_data_points.json
  def create
    @default_data_point = DefaultDataPoint.new(default_data_point_params)
    @default_data_point.user = current_user
    @default_data_point.route_id = params[:route_id]
    puts @default_data_point.inspect

    respond_to do |format|
      if @default_data_point.save
        format.html { redirect_to route_default_data_points_path(@route), notice: "Default data point was successfully created." }
        format.json { render :show, status: :created, location: @default_data_point }
      else
        @dropdown_options = @default_data_point.data_type.dropdown_options.order(:order_in_list)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @default_data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /default_data_points/1 or /default_data_points/1.json
  def update
    respond_to do |format|
      if @default_data_point.update(default_data_point_params)
        format.html { redirect_to route_default_data_points_path(@route), notice: "Default data point was successfully updated." }
        format.json { render :show, status: :ok, location: @default_data_point }
      else
        @dropdown_options = @default_data_point.data_type.dropdown_options.order(:order_in_list)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @default_data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /default_data_points/1 or /default_data_points/1.json
  def destroy
    @default_data_point.destroy
    respond_to do |format|
      format.html { redirect_to route_default_data_points_path(@route), notice: "This default data point was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_default_data_point
    @default_data_point = current_user.default_data_points.find(params[:id])
    @route = @default_data_point.route
  end

  def set_route
    @route = current_user.routes.find(params[:route_id])
  end

  # Only allow a list of trusted parameters through.
  def default_data_point_params
    params.require(:default_data_point).permit(:route_id, :data_type_id, :dropdown_option_id, :text_value, :decimal_value)
  end

end
