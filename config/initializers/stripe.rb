# config/initializers/stripe.rb
Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe&.dig(:publishable_key) || ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: Rails.application.credentials.stripe&.dig(:secret_key) || ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]