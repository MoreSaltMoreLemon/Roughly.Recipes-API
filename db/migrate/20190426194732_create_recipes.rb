class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :description
      t.integer :user_id
      t.decimal :scale_factor
      t.decimal :yield_in_grams
      t.decimal :yield
      t.integer :yield_unit_id, default: 1
      t.boolean :public

      t.timestamps
    end
  end
end
