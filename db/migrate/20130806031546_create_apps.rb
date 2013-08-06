class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.integer :uptime
      t.date :updated
      t.date :created
      t.integer :host_id

      t.timestamps
    end
  end
end
