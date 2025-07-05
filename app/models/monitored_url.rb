class MonitoredUrl < ApplicationRecord
  has_many :ping_results, dependent: :destroy

  validates :url, presence: true, format: URI::regexp(%w[http https])
  validates :name, presence: true
end
