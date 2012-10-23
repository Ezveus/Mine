class CreateUsers < ActiveRecord::Migration
  def self.up
    self.change
  end

  def change
    create_table :users do |t|
      t.string :name
      t.string :pass
      t.string :email
      t.string :website
      t.integer :isAdmin

      t.timestamps
    end

    def self.down
      drop_table :users
    end
  end
end
