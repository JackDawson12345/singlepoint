class CreateWebsiteServices < ActiveRecord::Migration[8.0]
  def change
    create_table :website_services do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
