class AdditionalDataTypesController < ApplicationController
  before_action :signed_in_user
  before_action :get_workout_types
  before_action :get_field_types
  before_action :set_workout_type, except: %i[ default_index edit update destroy move_up move_down]
  before_action :set_adt_and_workout_type, only: %i[ edit update destroy move_up move_down]


  def default_index
    @workout_type = @workout_types.first
    @additional_data_types = @workout_type.additional_data_types.order(:order_in_list)
    render :index
  end

  def index
    @additional_data_types = @workout_type.additional_data_types.order(:order_in_list)
  end

  # GET /additional_data_types/new
  def new
    @additional_data_type = AdditionalDataType.new
    @additional_data_type.workout_type = @workout_type
  end

  # GET /additional_data_types/1/edit
  def edit
  end

  # POST /additional_data_types or /additional_data_types.json
  def create
    @additional_data_type = AdditionalDataType.new(additional_data_type_params)
    @additional_data_type.user = current_user
    @additional_data_type.workout_type = current_user.workout_types.find(@workout_type.id)
    @additional_data_type.order_in_list = next_order_in_list(@workout_type.additional_data_types)

    respond_to do |format|
      if @additional_data_type.save
        format.html { redirect_to workout_type_additional_data_types_path(@workout_type), notice: "Additional data type was successfully created." }
        format.json { render :show, status: :created, location: @additional_data_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @additional_data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /additional_data_types/1 or /additional_data_types/1.json
  def update
    respond_to do |format|
      if @additional_data_type.update(additional_data_type_params)
        format.html { redirect_to workout_type_additional_data_types_path(@workout_type), notice: "Additional data type was successfully updated." }
        format.json { render :show, status: :ok, location: @additional_data_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @additional_data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def move_up
    move(true)
  end

  def move_down
    move(false)
  end

  # DELETE /additional_data_types/1 or /additional_data_types/1.json
  def destroy
    deleted_OIL = @additional_data_type.order_in_list
    @additional_data_type.destroy
    handle_delete_of_order_in_list(@workout_type.additional_data_types,deleted_OIL)
    respond_to do |format|
      format.html { redirect_to workout_type_additional_data_types_path(@workout_type), notice: "Additional data type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def get_workout_types
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def get_field_types
      @field_types = AdditionalDataType.field_types
    end

    def set_workout_type
      @workout_type = current_user.workout_types.find(params[:workout_type_id])
    end

    def set_adt_and_workout_type
      @additional_data_type = current_user.additional_data_types.find(params[:id])
      @workout_type = @additional_data_type.workout_type
    end

    # Only allow a list of trusted parameters through.
    def additional_data_type_params
      params.require(:additional_data_type).permit(:workout_type_id, :name, :field_type, :unit, :description)
    end

    def move(up)
      additional_data_type = current_user.additional_data_types.find(params[:id])
      workout_type = additional_data_type.workout_type
      move_in_list(workout_type.additional_data_types, workout_type_additional_data_types_path(workout_type), additional_data_type, up)
    end
end
