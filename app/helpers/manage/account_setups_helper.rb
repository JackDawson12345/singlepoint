# app/helpers/manage/account_setups_helper.rb
module Manage::AccountSetupsHelper
  def step_classes(step, current_step, steps)
    current_index = steps.index(current_step)
    step_index = steps.index(step)

    if step_index < current_index
      "bg-blue-600 text-white"  # Completed
    elsif step == current_step
      "bg-blue-600 text-white"  # Current
    else
      "bg-gray-200 text-gray-600"  # Not reached
    end
  end

  def step_complete?(step, current_step, steps)
    current_index = steps.index(current_step)
    step_index = steps.index(step)
    step_index < current_index
  end

  # Updated to use the model's pricing methods
  def calculate_display_amount(account_setup)
    account_setup.final_price
  end

  def format_price(amount)
    number_with_precision(amount, precision: 2)
  end

  def discount_badge
    content_tag :span, "20% OFF",
                class: "inline-block bg-green-100 text-green-800 text-xs font-semibold px-2 py-1 rounded-full"
  end
end