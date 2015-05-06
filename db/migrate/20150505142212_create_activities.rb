class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|

      t.belongs_to :event, index: true

      t.string :result


      t.timestamps null: false
    end
  end
end
