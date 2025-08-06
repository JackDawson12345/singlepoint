# app/controllers/manage/account_setups_controller.rb
class Manage::AccountSetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_customer_role
  before_action :set_account_setup
  before_action :set_current_step, only: [:step, :update_step]
  layout 'manage'

  def show
    # Redirect to the appropriate step
    redirect_to manage_account_setup_step_path(step: @account_setup.current_step)
  end

  def step
    case @current_step
    when 'confirmation'
      redirect_to manage_dashboard_path if @account_setup.completed?
    end
  end

  def update_step
    @account_setup.current_step = @current_step

    Rails.logger.info "=== DEBUG UPDATE_STEP ==="
    Rails.logger.info "Current Step: #{@current_step}"
    Rails.logger.info "Params: #{account_setup_params.inspect}"
    Rails.logger.info "Account Setup before update: #{@account_setup.attributes.inspect}"

    if @account_setup.update(account_setup_params)
      Rails.logger.info "Update successful!"
      if @current_step == 'payment'
        redirect_to manage_account_setup_step_path(step: 'payment')
      elsif @account_setup.next_step
        redirect_to manage_account_setup_step_path(step: @account_setup.next_step)
      else
        redirect_to manage_account_setup_step_path(step: 'confirmation')
      end
    else
      Rails.logger.info "Update failed!"
      Rails.logger.info "Errors: #{@account_setup.errors.full_messages.inspect}"
      render :step, status: :unprocessable_content
    end
  end

  def create_payment_intent
    # Use the new pricing method that includes discount
    amount = @account_setup.stripe_amount

    Rails.logger.info "=== PAYMENT INTENT CREATION ==="
    Rails.logger.info "Package: #{@account_setup.package_type}"
    Rails.logger.info "Support Option: #{@account_setup.support_option}"
    Rails.logger.info "Base Price: £#{@account_setup.base_price}"
    Rails.logger.info "Discount: £#{@account_setup.discount_amount}"
    Rails.logger.info "Final Price: £#{@account_setup.final_price}"
    Rails.logger.info "Stripe Amount (pence): #{amount}"

    begin
      intent = Stripe::PaymentIntent.create({
                                              amount: amount,
                                              currency: 'gbp',
                                              metadata: {
                                                account_setup_id: @account_setup.id,
                                                user_id: current_user.id,
                                                package_type: @account_setup.package_type,
                                                support_option: @account_setup.support_option,
                                                base_price: @account_setup.base_price,
                                                discount_amount: @account_setup.discount_amount,
                                                final_price: @account_setup.final_price
                                              }
                                            })

      @account_setup.update(
        stripe_payment_intent_id: intent.id,
        payment_status: 'processing'
      )

      render json: { client_secret: intent.client_secret }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe Error: #{e.message}"
      render json: { error: e.message }, status: 422
    end
  end

  def confirm_payment
    if @account_setup.stripe_payment_intent_id.present?
      begin
        intent = Stripe::PaymentIntent.retrieve(@account_setup.stripe_payment_intent_id)

        if intent.status == 'succeeded'
          @account_setup.update(
            payment_status: 'completed',
            paid_at: Time.current
          )
          redirect_to manage_account_setup_step_path(step: 'confirmation')
        else
          @account_setup.update(payment_status: 'failed')
          redirect_to manage_account_setup_step_path(step: 'payment'),
                      alert: 'Payment was not successful. Please try again.'
        end
      rescue Stripe::StripeError => e
        redirect_to manage_account_setup_step_path(step: 'payment'),
                    alert: 'Error confirming payment. Please contact support.'
      end
    else
      redirect_to manage_account_setup_step_path(step: 'payment')
    end
  end

  private

  def set_account_setup
    @account_setup = current_user.account_setup || current_user.build_account_setup
    @account_setup.save if @account_setup.new_record?
  end

  def set_current_step
    @current_step = params[:step] || @account_setup.current_step
    @current_step = 'domain' unless @account_setup.steps.include?(@current_step)
    @account_setup.current_step = @current_step
  end

  def ensure_customer_role
    redirect_to root_path unless current_user.role == 1
  end

  def account_setup_params
    case @current_step
    when 'domain'
      params.require(:account_setup).permit(:domain_name)
    when 'package'
      params.require(:account_setup).permit(:package_type)
    when 'support'
      params.require(:account_setup).permit(:support_option)
    else
      {}
    end
  end
end