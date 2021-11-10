class AdditionalDataTypeOptionsController < ApplicationController
  before_action :signed_in_user
  before_action :set_adt, except: %i[ edit update destroy move_up move_down]
  before_action :set_adto_and_adt, only: %i[ edit update destroy move_up move_down ]
  before_action :set_workout_type
  before_action :get_workout_types
  before_action :get_additional_data_types


  # GET /additional_data_type_options or /additional_data_type_options.json
  def index
    @additional_data_type_options = current_user.additional_data_type_options.order(:order_in_list)
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
    @additional_data_type_option.user = current_user
    @additional_data_type_option.additional_data_type = current_user.additional_data_types.find(@additional_data_type.id)
    @additional_data_type_option.order_in_list = next_order_in_list(@additional_data_type.additional_data_type_options)

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

  def move_up
    move(true)
  end

  def move_down
    move(false)
  end

  # DELETE /additional_data_type_options/1 or /additional_data_type_options/1.json
  def destroy
    deleted_OIL = @additional_data_type_option.order_in_list
    adt = @additional_data_type_option.additional_data_type
    @additional_data_type_option.destroy
    handle_delete_of_order_in_list(adt.additional_data_type_options,deleted_OIL)
    respond_to do |format|
      format.html { redirect_to additional_data_type_options_url(adt), notice: "Workout type additional data type option was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def get_workout_types
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def set_workout_type
      @workout_type = @additional_data_type.workout_type
    end

    def get_additional_data_types
      @additional_data_types = @workout_type.additional_data_types.order(:order_in_list)
    end

    def set_adt
      @additional_data_type = current_user.additional_data_types.find(params[:additional_data_type_id])
    end

    def set_adto_and_adt
      @additional_data_type_option = current_user.additional_data_type_options.find(params[:id])
      @additional_data_type = @additional_data_type_option.additional_data_type
    end

    # Only allow a list of trusted parameters through.
    def additional_data_type_option_params
      params.require(:additional_data_type_option).permit(:additional_data_type_id, :name)
    end

    def move(up)
      adto = current_user.additional_data_type_options.find(params[:id])
      additional_data_type = adto.additional_data_type
      move_in_list(additional_data_type.additional_data_type_options, additional_data_type_options_path(additional_data_type), adto, up)
    end
end
