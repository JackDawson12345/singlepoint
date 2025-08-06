# app/models/account_setup.rb
class AccountSetup < ApplicationRecord
  belongs_to :user

  attr_accessor :current_step

  # Set default values
  before_validation :set_defaults, on: :create

  # Step-based validations - only validate what's needed for the current step
  validate :step_validations

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[domain package support payment confirmation]
  end

  def next_step
    current_index = steps.index(current_step)
    steps[current_index + 1] if current_index < steps.length - 1
  end

  def previous_step
    current_index = steps.index(current_step)
    steps[current_index - 1] if current_index > 0
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def completed?
    payment_status == 'completed' && paid_at.present?
  end

  # Pricing methods
  def base_price
    case package_type
    when 'bespoke'
      2999.00
    when 'ecommerce'
      4999.00
    else
      0.00
    end
  end

  def discount_amount
    return 0.00 unless support_option == 'need_help'
    (base_price * 0.80).round(2)  # 20% discount
  end

  def final_price
    (base_price - discount_amount).round(2)
  end

  def has_discount?
    support_option == 'need_help'
  end

  def discount_percentage
    has_discount? ? 80 : 0
  end

  # Price in pence for Stripe (multiply by 100)
  def stripe_amount
    (final_price * 100).to_i
  end

  private

  def set_defaults
    self.payment_status ||= 'pending'
  end

  def step_validations
    case current_step
    when 'domain'
      validate_domain
    when 'package'
      validate_domain
      validate_package
    when 'support'
      validate_domain
      validate_package
      validate_support
    when 'payment', 'confirmation'
      validate_domain
      validate_package
      validate_support
    end
  end

  def validate_domain
    if domain_name.blank?
      errors.add(:domain_name, "can't be blank")
    elsif !domain_name.match?(/\A[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}\z/)
      errors.add(:domain_name, "must be a valid domain name (e.g., example.com)")
    end
  end

  def validate_package
    if package_type.blank?
      errors.add(:package_type, "can't be blank")
    elsif !%w[bespoke ecommerce].include?(package_type)
      errors.add(:package_type, "must be either bespoke or ecommerce")
    end
  end

  def validate_support
    if support_option.blank?
      errors.add(:support_option, "can't be blank")
    elsif !%w[do_it_myself need_help].include?(support_option)
      errors.add(:support_option, "must be either do_it_myself or need_help")
    end
  end
end