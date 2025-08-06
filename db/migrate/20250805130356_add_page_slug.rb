class AddPageSlug < ActiveRecord::Migration[8.0]
  def change
    add_column :theme_pages, :slug, :string
  end
end
