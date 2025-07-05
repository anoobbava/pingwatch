class RemoveUserIdFromMonitoredUrls < ActiveRecord::Migration[7.1]
  def change
    remove_reference :monitored_urls, :user, null: false, foreign_key: true
  end
end 