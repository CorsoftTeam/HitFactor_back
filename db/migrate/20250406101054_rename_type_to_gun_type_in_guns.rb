class RenameTypeToGunTypeInGuns < ActiveRecord::Migration[7.2]
  def change
    rename_column :guns, :type, :gun_type
  end
end
