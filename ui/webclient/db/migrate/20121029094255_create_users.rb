class CreateUsers < ActiveRecord::Migration
  def up
    change
  end

  def change
    create_table :users do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
