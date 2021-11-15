class DropdownOptionsController < ApplicationController
  before_action :signed_in_user
  before_action :set_dt, except: %i[ edit update destroy move_up move_down]
  before_action :set_dto_and_dt, only: %i[ edit update destroy move_up move_down ]
  before_action :set_workout_type
  before_action :get_workout_types
  before_action :get_data_types


  # GET /dropdown_options or /dropdown_options.json
  def index
    @dropdown_options = @data_type.dropdown_options.order(:order_in_list)
  end

  # GET /dropdown_options/1 or /dropdown_options/1.json
  def show
  end

  # GET /dropdown_options/new
  def new
    @dropdown_option = DropdownOption.new
  end

  # GET /dropdown_options/1/edit
  def edit
  end

  # POST /dropdown_options or /dropdown_options.json
  def create
    @dropdown_option = DropdownOption.new(dropdown_option_params)
    @dropdown_option.user = current_user
    @dropdown_option.data_type = current_user.data_types.find(@data_type.id)
    @dropdown_option.order_in_list = next_order_in_list(@data_type.dropdown_options)

    respond_to do |format|
      if @dropdown_option.save
        format.html { redirect_to data_type_dropdown_options_path(@data_type), notice: "Dropdown option was successfully created." }
        format.json { render :show, status: :created, location: @dropdown_option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dropdown_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dropdown_options/1 or /dropdown_options/1.json
  def update
    respond_to do |format|
      if @dropdown_option.update(dropdown_option_params)
        format.html { redirect_to data_type_dropdown_options_path(@data_type), notice: "Dropdown option was successfully updated." }
        format.json { render :show, status: :ok, location: @dropdown_option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dropdown_option.errors, status: :unprocessable_entity }
      end
    end
  end

  def move_up
    move(true)
  end

  def move_down
    move(false)
  end

  # DELETE /dropdown_options/1 or /dropdown_options/1.json
  def destroy
    deleted_OIL = @dropdown_option.order_in_list
    dt = @dropdown_option.data_type
    @dropdown_option.destroy
    handle_delete_of_order_in_list(dt.dropdown_options,deleted_OIL)
    respond_to do |format|
      format.html { redirect_to data_type_dropdown_options_path(dt), notice: "Dropdown option was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def get_workout_types
      @workout_types = current_user.workout_types.order(:order_in_list)
    end

    def set_workout_type
      @workout_type = @data_type.workout_type
    end

    def get_data_types
      ft_dropdown = DataType.field_types_hash[:dropdown]
      @data_types = @workout_type.data_types.where(field_type: ft_dropdown).order(:order_in_list)
    end

    def set_dt
      @data_type = current_user.data_types.find(params[:data_type_id])
    end

    def set_dto_and_dt
      @dropdown_option = current_user.dropdown_options.find(params[:id])
      @data_type = @dropdown_option.data_type
    end

    # Only allow a list of trusted parameters through.
    def dropdown_option_params
      params.require(:dropdown_option).permit(:data_type_id, :name)
    end

    def move(up)
      dto = current_user.dropdown_options.find(params[:id])
      dt = dto.data_type
      move_in_list(dt.dropdown_options, data_type_dropdown_options_path(dt), dto, up)
    end
end
