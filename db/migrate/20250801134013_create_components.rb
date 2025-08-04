class CreateComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :components do |t|
      t.string :name
      t.text :html_content
      t.text :css_content
      t.text :js_content
      t.text :editable_fields
      t.text :component_type
      t.text :template_patterns
      t.boolean :global, default: false
      t.text :field_types

      t.timestamps
    end
  end
end
