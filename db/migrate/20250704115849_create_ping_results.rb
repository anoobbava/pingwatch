class CreatePingResults < ActiveRecord::Migration[7.1]
  def change
    create_table :ping_results do |t|
      t.references :monitored_url, null: false, foreign_key: true
      t.integer :status_code
      t.float :response_time
      t.string :error_message

      t.timestamps
    end
  end
end
