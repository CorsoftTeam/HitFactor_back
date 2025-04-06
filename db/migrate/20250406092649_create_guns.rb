class CreateGuns < ActiveRecord::Migration[7.2]
  def change
    create_table :guns do |t|
      t.string :name
      t.string :type
      t.float :caliber
      t.integer :magazine_size
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
