class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :name
      t.string :organization
      t.references :user, foreign_key: true
      t.integer :age
      t.boolean :arrived

      t.timestamps
    end
  end
end
