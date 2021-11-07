class AdditionalDataTypeValuesController < ApplicationController
  before_action :signed_in_user
  before_action :set_additional_data_type_value, only: %i[ show edit update destroy ]

  # GET /additional_data_type_values or /additional_data_type_values.json
  def index
    @additional_data_type_values = current_user.additional_data_type_values.all
  end

  # GET /additional_data_type_values/1 or /additional_data_type_values/1.json
  def show
  end

  # GET /additional_data_type_values/new
  def new
    @additional_data_type_value = AdditionalDataTypeValue.new
  end

  # GET /additional_data_type_values/1/edit
  def edit
  end

  # POST /additional_data_type_values or /additional_data_type_values.json
  def create
    @additional_data_type_value = AdditionalDataTypeValue.new(additional_data_type_value_params)
    @additional_data_type_value.user = current_user

    respond_to do |format|
      if @additional_data_type_value.save
        format.html { redirect_to @additional_data_type_value, notice: "Workout type additional data type value was successfully created." }
        format.json { render :show, status: :created, location: @additional_data_type_value }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @additional_data_type_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /additional_data_type_values/1 or /additional_data_type_values/1.json
  def update
    respond_to do |format|
      if @additional_data_type_value.update(additional_data_type_value_params)
        format.html { redirect_to @additional_data_type_value, notice: "Workout type additional data type value was successfully updated." }
        format.json { render :show, status: :ok, location: @additional_data_type_value }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @additional_data_type_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_data_type_values/1 or /additional_data_type_values/1.json
  def destroy
    @additional_data_type_value.destroy
    respond_to do |format|
      format.html { redirect_to additional_data_type_values_url, notice: "Workout type additional data type value was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additional_data_type_value
      @additional_data_type_value = current_user.additional_data_type_values.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def additional_data_type_value_params
      params.require(:additional_data_type_value).permit(:user_id, :workout_id, :additional_data_type_id, :additional_data_type_option_id)
    end
end
