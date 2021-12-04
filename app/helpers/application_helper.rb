module ApplicationHelper

  def next_order_in_list(list_of_objects)
    #for setting the order_in_list
    max = list_of_objects.maximum(:order_in_list)
    return max.nil? ? 1 : max + 1
  end

  def move_in_list(list_of_objects, redirect_path, current_object, up = true)
    o = current_object

    if o.present?
      o2 = get_adjacent(list_of_objects, o, up)
      if o2.present?
        swap_and_save(o, o2)
        redirect_to redirect_path
        return
      end
    end
    redirect_to redirect_path, notice: "could not move"
  end

  def get_adjacent(list_of_objects, current, get_previous = false)
    if get_previous
      list_of_objects.where("order_in_list < ?",
                                  current.order_in_list).order("order_in_list DESC").first
    else
      list_of_objects.where("order_in_list > ?", current.order_in_list).order(:order_in_list).first
    end
  end

  def swap_and_save(first, second)
    temp_value = first.class.maximum(:order_in_list) + 1
    if first.order_in_list > second.order_in_list
      first_new_value = second.order_in_list
      second.order_in_list = first_new_value + 1 #if there's space in between due to deletions, move up
    else
      second.order_in_list = first.order_in_list
      first_new_value = second.order_in_list + 1 #if there's space in between due to deletions, move up
    end
    first.order_in_list = temp_value
    throw "error swapping order_in_list" unless first.save
    throw "error swapping order_in_list" unless second.save
    first.order_in_list = first_new_value
    throw "error swapping order_in_list" unless first.save
  end

  def handle_delete_of_order_in_list(list_of_objects,deleted_order_in_list)
    list_of_objects.where("order_in_list > ?",deleted_order_in_list).order(:order_in_list).each do |obj|
      obj.order_in_list -= 1
      obj.save
    end
  end

  def nil_to_zero(variable)
    return variable if variable.present?
    0
  end
end
