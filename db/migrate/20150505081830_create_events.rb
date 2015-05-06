class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.float :duration, null: false, default: 1
      t.string :timezone, null: false, default: "UTC"
      t.string :email, null: false

      t.timestamps null: false
    end
  end
end
