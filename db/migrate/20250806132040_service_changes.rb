class ServiceChanges < ActiveRecord::Migration[8.0]
  def change
    add_column :website_services, :features, :json
    add_column :website_services, :icon, :string
  end
end
