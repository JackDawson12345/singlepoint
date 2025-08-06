class CreateWebsitesCustomisations < ActiveRecord::Migration[8.0]
  def change
    create_table :websites_customisations do |t|
      t.references :website, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.references :theme_page, null: false, foreign_key: true
      t.string :field_name
      t.string :field_value
      t.string :field_styling

      t.timestamps
    end
  end
end
