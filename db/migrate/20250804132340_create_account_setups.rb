class CreateAccountSetups < ActiveRecord::Migration[8.0]
  def change
    create_table :account_setups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :domain_name
      t.string :package_type
      t.string :support_option
      t.string :payment_status, default: 'pending'
      t.string :stripe_payment_intent_id
      t.datetime :paid_at

      t.timestamps
    end


  end

end
