class CreateMonitoredUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :monitored_urls do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
