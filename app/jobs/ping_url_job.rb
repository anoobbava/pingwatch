class PingUrlJob < ApplicationJob
  queue_as :default

  def perform(monitored_url_id)
    url = MonitoredUrl.find_by(id: monitored_url_id)
    return unless url&.active?

    start_time = Time.now
    begin
      response = HTTParty.get(url.url, timeout: 10)
      status_code = response.code
      error_message = nil
    rescue => e
      status_code = nil
      error_message = e.message
    end
    response_time = ((Time.now - start_time) * 1000).round(2)

    url.ping_results.create!(
      status_code: status_code,
      response_time: response_time,
      error_message: error_message
    )
  end
end
