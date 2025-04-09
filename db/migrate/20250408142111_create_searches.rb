class CreateSearches < ActiveRecord::Migration[6.1]
  def change
    create_table :searches do |t|
      t.string :query, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
