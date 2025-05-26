class AddShotCountToGuns < ActiveRecord::Migration[7.2]
  def change
    add_column :guns, :shot_count, :integer, default: 0
  end
end
