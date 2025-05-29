class AddNeytoTypeToGuns < ActiveRecord::Migration[7.2]
  def change
    add_column :guns, :neyro_type, :string
  end
end
