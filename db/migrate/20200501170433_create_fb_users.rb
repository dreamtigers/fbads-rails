class CreateFbUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :fb_users, id: false do |t|
      t.primary_key :sno
      t.string :uid
      t.string :name
      t.string :email
      t.string :token
      t.string :adaccount
      t.string :pageID
      t.string :url
      t.integer :active

      t.timestamps
    end
    add_index :fb_users, :uid, unique: true
  end
end
