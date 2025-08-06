class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :account_setup, dependent: :destroy
  has_one :website, dependent: :destroy

  # Instance method to get name with fallback options
  def display_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}".strip
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    else
      email&.split('@')&.first || 'User'
    end
  end

  def role_name
    if role == 0
      'Admin'
    elsif role == 1
      'Customer'
    else
      'No Role'
    end
  end


end
