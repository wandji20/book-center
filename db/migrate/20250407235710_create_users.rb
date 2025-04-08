class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :ip_address, unique: true

      t.timestamps
    end
    add_index :users, :ip_address
  end
end
