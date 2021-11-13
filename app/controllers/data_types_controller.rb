class DataTypesController < ApplicationController
  before_action :signed_in_user
  before_action :get_workout_types
  before_action :get_field_types
  before_action :set_workout_type, except: %i[ default_index edit update destroy move_up move_down]
  before_action :set_dt_and_workout_type, only: %i[ edit update destroy move_up move_down]

  def default_index
    @workout_type = @workout_types.first
    @data_types = @workout_type.data_types.order(:order_in_list)
    render :index
  end

  def index
    @data_types = @workout_type.data_types.order(:order_in_list)
  end

  # GET /data_types/new
  def new
    @data_type = DataType.new
    @data_type.workout_type = @workout_type
  end

  # GET /data_types/1/edit
  def edit
  end

  # POST /data_types or /data_types.json
  def create
    @data_type = DataType.new(data_type_params)
    @data_type.user = current_user
    @data_type.workout_type = current_user.workout_types.find(@workout_type.id)
    @data_type.order_in_list = next_order_in_list(@workout_type.data_types)

    respond_to do |format|
      if @data_type.save
        format.html { redirect_to workout_type_data_types_path(@workout_type), notice: "Additional data type was successfully created." }
        format.json { render :show, status: :created, location: @data_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_types/1 or /data_types/1.json
  def update
    respond_to do |format|
      if @data_type.update(data_type_params)
        format.html { redirect_to workout_type_data_types_path(@workout_type), notice: "Additional data type was successfully updated." }
        format.json { render :show, status: :ok, location: @data_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def move_up
    move(true)
  end

  def move_down
    move(false)
  end

  # DELETE /data_types/1 or /data_types/1.json
  def destroy
    deleted_OIL = @data_type.order_in_list
    @data_type.destroy
    handle_delete_of_order_in_list(@workout_type.data_types,deleted_OIL)
    respond_to do |format|
      format.html { redirect_to workout_type_data_types_path(@workout_type), notice: "Additional data type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def get_workout_types
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def get_field_types
      @field_types = DataType.field_types
    end

    def set_workout_type
      @workout_type = current_user.workout_types.find(params[:workout_type_id])
    end

    def set_dt_and_workout_type
      @data_type = current_user.data_types.find(params[:id])
      @workout_type = @data_type.workout_type
    end

    # Only allow a list of trusted parameters through.
    def data_type_params
      params.require(:data_type).permit(:workout_type_id, :name, :field_type, :unit, :description)
    end

    def move(up)
      data_type = current_user.data_types.find(params[:id])
      workout_type = data_type.workout_type
      move_in_list(workout_type.data_types, workout_type_data_types_path(workout_type), data_type, up)
    end
end
