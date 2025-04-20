class ComplexGunsMigration < ActiveRecord::Migration[7.2]
  def change
    # Удаление колонок
    remove_column :guns, :magazine_size
    
    # Добавление новых колонок
    add_column :guns, :serial_number, :string
    
    # Изменение типа данных существующей колонки
    change_column :guns, :caliber, :string
  end
end
