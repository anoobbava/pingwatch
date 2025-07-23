# config/initializers/prometheus.rb

if defined?(Sidekiq) && Sidekiq.server?
    # SIDEKIQ SETUP
    require 'prometheus_exporter/instrumentation'
    require 'prometheus_exporter/client'
  
    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add PrometheusExporter::Instrumentation::Sidekiq
      end

      config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
  
      config.on(:startup) do
        PrometheusExporter::Instrumentation::Process.start(type: 'sidekiq')
        PrometheusExporter::Instrumentation::SidekiqProcess.start
        PrometheusExporter::Instrumentation::SidekiqQueue.start
        PrometheusExporter::Instrumentation::SidekiqStats.start
      end
    end
  
  else
    # WEB SETUP
    require 'prometheus_exporter/middleware'
    require 'prometheus_exporter/instrumentation'
  
    Rails.application.middleware.unshift PrometheusExporter::Middleware
  
    PrometheusExporter::Instrumentation::Process.start(type: 'web')
  end
