namespace :pingwatch do
  desc 'Enqueue ping jobs for all active monitored URLs'
  task ping_all: :environment do
    MonitoredUrl.where(active: true).find_each do |url|
      PingUrlJob.perform_later(url.id)
    end
  end
end 