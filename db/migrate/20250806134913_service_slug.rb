class ServiceSlug < ActiveRecord::Migration[8.0]
  def change
    add_column :website_services, :slug, :string
  end
end
