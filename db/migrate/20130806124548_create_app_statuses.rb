class CreateAppStatuses < ActiveRecord::Migration
  def change
    create_table :app_statuses do |t|
      t.float :cpu
      t.float :memory

      t.timestamps
    end
  end
end
