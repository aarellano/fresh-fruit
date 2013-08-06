class AddAppIdToAppStatus < ActiveRecord::Migration
  def change
    add_column :app_statuses, :app_id, :integer
  end
end
