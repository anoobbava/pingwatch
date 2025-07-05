class DashboardController < ApplicationController
  def index
    @monitored_urls = MonitoredUrl.includes(:ping_results)
  end
end
