class AdditionalDataTypeOptionsController < ApplicationController
  before_action :signed_in_user
  before_action :set_additional_data_type_option, only: %i[ show edit update destroy ]

  # GET /additional_data_type_options or /additional_data_type_options.json
  def index
    @additional_data_type_options = AdditionalDataTypeOption.all
  end

  # GET /additional_data_type_options/1 or /additional_data_type_options/1.json
  def show
  end

  # GET /additional_data_type_options/new
  def new
    @additional_data_type_option = AdditionalDataTypeOption.new
  end

  # GET /additional_data_type_options/1/edit
  def edit
  end

  # POST /additional_data_type_options or /additional_data_type_options.json
  def create
    @additional_data_type_option = AdditionalDataTypeOption.new(additional_data_type_option_params)

    respond_to do |format|
      if @additional_data_type_option.save
        format.html { redirect_to @additional_data_type_option, notice: "Workout type additional data type option was successfully created." }
        format.json { render :show, status: :created, location: @additional_data_type_option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @additional_data_type_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /additional_data_type_options/1 or /additional_data_type_options/1.json
  def update
    respond_to do |format|
      if @additional_data_type_option.update(additional_data_type_option_params)
        format.html { redirect_to @additional_data_type_option, notice: "Workout type additional data type option was successfully updated." }
        format.json { render :show, status: :ok, location: @additional_data_type_option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @additional_data_type_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_data_type_options/1 or /additional_data_type_options/1.json
  def destroy
    @additional_data_type_option.destroy
    respond_to do |format|
      format.html { redirect_to additional_data_type_options_url, notice: "Workout type additional data type option was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additional_data_type_option
      @additional_data_type_option = AdditionalDataTypeOption.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def additional_data_type_option_params
      params.require(:additional_data_type_option).permit(:user_id, :additional_data_type_id, :name, :order_in_list)
    end
end
