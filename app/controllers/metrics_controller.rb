class MetricsController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_urls = current_user.monitored_urls.count
    @active_urls = current_user.monitored_urls.joins(:ping_results).where(ping_results: { status_code: 200 }).distinct.count
    
    # Calculate overall statistics
    @total_pings = PingResult.joins(:monitored_url).where(monitored_urls: { user: current_user }).count
    @successful_pings = PingResult.joins(:monitored_url).where(monitored_urls: { user: current_user }, status_code: 200).count
    @failed_pings = @total_pings - @successful_pings
    @avg_uptime = @total_pings > 0 ? ((@successful_pings.to_f / @total_pings) * 100).round(1) : 0
    
    # Response time statistics
    @avg_response_time = PingResult.joins(:monitored_url).where(monitored_urls: { user: current_user }).average(:response_time)&.round(0) || 0
    @fastest_response = PingResult.joins(:monitored_url).where(monitored_urls: { user: current_user }).minimum(:response_time)&.round(0) || 0
    @slowest_response = PingResult.joins(:monitored_url).where(monitored_urls: { user: current_user }).maximum(:response_time)&.round(0) || 0
    
    # Get recent activity
    @recent_pings = PingResult.joins(:monitored_url)
                              .where(monitored_urls: { user: current_user })
                              .order(created_at: :desc)
                              .limit(50)
    
    # Get top performing URLs
    @top_urls = current_user.monitored_urls.joins(:ping_results)
                           .group('monitored_urls.id')
                           .select('monitored_urls.*, AVG(ping_results.response_time) as avg_response_time, COUNT(ping_results.id) as total_checks')
                           .order('avg_response_time ASC')
                           .limit(5)
    
    # Get URLs with most downtime
    @problem_urls = current_user.monitored_urls.joins(:ping_results)
                               .group('monitored_urls.id')
                               .select('monitored_urls.*, COUNT(CASE WHEN ping_results.status_code != 200 THEN 1 END) as failed_checks, COUNT(ping_results.id) as total_checks')
                               .having('COUNT(ping_results.id) > 0')
                               .order('failed_checks DESC')
                               .limit(5)
  end
end
