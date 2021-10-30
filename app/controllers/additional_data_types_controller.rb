class AdditionalDataTypesController < ApplicationController
  before_action :signed_in_user
  before_action :set_additional_data_type, only: %i[ show edit update destroy ]

  # GET /additional_data_types or /additional_data_types.json
  def index
    @additional_data_types = AdditionalDataType.all
  end

  # GET /additional_data_types/1 or /additional_data_types/1.json
  def show
  end

  # GET /additional_data_types/new
  def new
    @additional_data_type = AdditionalDataType.new
  end

  # GET /additional_data_types/1/edit
  def edit
  end

  # POST /additional_data_types or /additional_data_types.json
  def create
    @additional_data_type = AdditionalDataType.new(additional_data_type_params)

    respond_to do |format|
      if @additional_data_type.save
        format.html { redirect_to @additional_data_type, notice: "Workout type additional data type was successfully created." }
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
        format.html { redirect_to @additional_data_type, notice: "Workout type additional data type was successfully updated." }
        format.json { render :show, status: :ok, location: @additional_data_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @additional_data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_data_types/1 or /additional_data_types/1.json
  def destroy
    @additional_data_type.destroy
    respond_to do |format|
      format.html { redirect_to additional_data_types_url, notice: "Workout type additional data type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additional_data_type
      @additional_data_type = AdditionalDataType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def additional_data_type_params
      params.require(:additional_data_type).permit(:user_id, :workout_type_id, :data_type_name, :order_in_list)
    end
end
