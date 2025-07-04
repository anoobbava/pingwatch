class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @monitored_urls = current_user.monitored_urls.includes(:ping_results)
  end
end
