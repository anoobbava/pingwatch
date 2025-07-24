# lib/tasks/load_seeder.rake
namespace :grafana do
  desc "Populate data for Grafana dashboard testing"
  task populate_data: :environment do
    puts "🚀 Starting Grafana data population..."
    
    # Create test monitored URLs if they don't exist
    urls = [
      { name: "Google", url: "https://www.google.com", active: true },
      { name: "GitHub", url: "https://github.com", active: true },
      { name: "Stack Overflow", url: "https://stackoverflow.com", active: true },
      { name: "HTTPBin", url: "https://httpbin.org/delay/1", active: true },
      { name: "Slow Site", url: "https://httpbin.org/delay/3", active: true },
      { name: "Failing Site", url: "https://httpbin.org/status/500", active: true },
      { name: "Timeout Site", url: "https://httpbin.org/delay/15", active: true }
    ]
    
    urls.each do |url_data|
      MonitoredUrl.find_or_create_by(name: url_data[:name]) do |url|
        url.url = url_data[:url]
        url.active = url_data[:active]
      end
    end
    
    puts "✅ Created #{urls.length} monitored URLs"
    
    # Generate Sidekiq jobs for each URL
    puts "🔄 Generating Sidekiq jobs..."
    
    1000.times do |i|
      # Randomly select a monitored URL
      monitored_url = MonitoredUrl.all.sample
      PingUrlJob.perform_later(monitored_url.id)
      
      if (i + 1) % 100 == 0
        puts "  Created #{i + 1} jobs..."
      end
    end
    
    puts "✅ Generated 1000 Sidekiq jobs"
    
    # Generate some immediate ping results for instant data
    puts "🌐 Generating immediate ping results..."
    
    50.times do |i|
      monitored_url = MonitoredUrl.all.sample
      
      # Simulate different response scenarios
      case i % 4
      when 0
        # Success
        status_code = 200
        response_time = rand(50..500)
        error_message = nil
      when 1
        # Slow response
        status_code = 200
        response_time = rand(1000..3000)
        error_message = nil
      when 2
        # Error
        status_code = 500
        response_time = rand(100..500)
        error_message = "Server Error"
      when 3
        # Timeout
        status_code = nil
        response_time = 10000
        error_message = "Timeout"
      end
      
      monitored_url.ping_results.create!(
        status_code: status_code,
        response_time: response_time,
        error_message: error_message,
        created_at: Time.current - rand(0..3600).seconds
      )
    end
    
    puts "✅ Generated 50 immediate ping results"
    
    # Generate HTTP traffic for Rails metrics
    puts "🌍 Generating HTTP traffic..."
    
    # Determine the base URL for HTTP requests
    base_url = ENV['RAILS_ENV'] == 'production' ? 'http://pingwatch:3000' : 'http://localhost:3000'
    
    200.times do |i|
      # Simulate different controller actions
      actions = [
        { controller: "monitored_urls", action: "index" },
        { controller: "monitored_urls", action: "show" },
        { controller: "dashboard", action: "index" },
        { controller: "metrics", action: "index" }
      ]
      
      action = actions.sample
      
      # This will generate HTTP request metrics
      begin
        HTTParty.get("#{base_url}/#{action[:controller]}")
      rescue => e
        # Ignore connection errors in this context
        puts "  HTTP request failed: #{e.message}" if i % 50 == 0
      end
      
      sleep 0.1 if i % 50 == 0
    end
    
    puts "✅ Generated HTTP traffic"
    
    # Final stats
    puts "\n📈 Final Statistics:"
    puts "  Monitored URLs: #{MonitoredUrl.count}"
    puts "  Ping Results: #{PingResult.count}"
    puts "  Sidekiq Queue Size: #{Sidekiq::Queue.new.size}"
    puts "  Sidekiq Processed Jobs: #{Sidekiq::Stats.new.processed}"
    
    puts "\n🎉 Grafana data population complete!"
    puts "   Check your Grafana dashboard now!"
    puts "   Access Grafana at: http://$(minikube ip):30001 (admin/admin123)"
    puts "   Access Prometheus at: http://$(minikube ip):30090"
  end
  
  desc "Generate continuous load for real-time monitoring"
  task generate_load: :environment do
    puts "🔄 Starting continuous load generation (Ctrl+C to stop)..."
    
    # Determine the base URL for HTTP requests
    base_url = ENV['RAILS_ENV'] == 'production' ? 'http://pingwatch:3000' : 'http://localhost:3000'
    
    loop do
      # Generate jobs
      20.times do
        monitored_url = MonitoredUrl.all.sample
        PingUrlJob.perform_later(monitored_url.id)
      end
      
      # Generate HTTP traffic
      10.times do
        begin
          HTTParty.get("#{base_url}/monitored_urls")
        rescue => e
          # Ignore connection errors
          puts "HTTP request failed: #{e.message}" if rand < 0.1
        end
      end
      
      puts "Generated load at #{Time.current}"
      sleep 30
    end
  end
  
  desc "Clear all test data"
  task clear_data: :environment do
    puts "🗑️ Clearing all test data..."
    
    PingResult.delete_all
    MonitoredUrl.delete_all
    
    puts "✅ All test data cleared"
  end
  
  desc "Show current statistics"
  task stats: :environment do
    puts "\n📊 Current Statistics:"
    puts "  Monitored URLs: #{MonitoredUrl.count}"
    puts "  Ping Results: #{PingResult.count}"
    puts "  Sidekiq Queue Size: #{Sidekiq::Queue.new.size}"
    puts "  Sidekiq Processed Jobs: #{Sidekiq::Stats.new.processed}"
    
    if MonitoredUrl.count > 0
      puts "\n📈 Recent Ping Results:"
      PingResult.order(created_at: :desc).limit(5).each do |result|
        status = result.status_code == 200 ? "✅" : "❌"
        puts "  #{status} #{result.monitored_url.name}: #{result.response_time}ms (#{result.status_code})"
      end
    end
  end
end