class DefaultDataPointsController < ApplicationController
  before_action :set_default_data_point, only: %i[ show edit update destroy ]

  # GET /default_data_points or /default_data_points.json
  def index
    @default_data_points = DefaultDataPoint.all
  end

  # GET /default_data_points/1 or /default_data_points/1.json
  def show
  end

  # GET /default_data_points/new
  def new
    @default_data_point = DefaultDataPoint.new
  end

  # GET /default_data_points/1/edit
  def edit
  end

  # POST /default_data_points or /default_data_points.json
  def create
    @default_data_point = DefaultDataPoint.new(default_data_point_params)

    respond_to do |format|
      if @default_data_point.save
        format.html { redirect_to @default_data_point, notice: "Default data point was successfully created." }
        format.json { render :show, status: :created, location: @default_data_point }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @default_data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /default_data_points/1 or /default_data_points/1.json
  def update
    respond_to do |format|
      if @default_data_point.update(default_data_point_params)
        format.html { redirect_to @default_data_point, notice: "Default data point was successfully updated." }
        format.json { render :show, status: :ok, location: @default_data_point }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @default_data_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /default_data_points/1 or /default_data_points/1.json
  def destroy
    @default_data_point.destroy
    respond_to do |format|
      format.html { redirect_to default_data_points_url, notice: "Default data point was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_default_data_point
      @default_data_point = DefaultDataPoint.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def default_data_point_params
      params.fetch(:default_data_point, {})
    end
end
