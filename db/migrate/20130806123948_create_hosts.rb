class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :name
      t.integer :total_memory
      t.integer :free_memory
      t.float :cpu_load

      t.timestamps
    end
  end
end
