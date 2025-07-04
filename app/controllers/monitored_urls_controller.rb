class MonitoredUrlsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_monitored_url, only: %i[ show edit update destroy ]

  # GET /monitored_urls or /monitored_urls.json
  def index
    @monitored_urls = current_user.monitored_urls
  end

  # GET /monitored_urls/1 or /monitored_urls/1.json
  def show
  end

  # GET /monitored_urls/new
  def new
    @monitored_url = current_user.monitored_urls.new
  end

  # GET /monitored_urls/1/edit
  def edit
  end

  # POST /monitored_urls or /monitored_urls.json
  def create
    @monitored_url = current_user.monitored_urls.new(monitored_url_params)

    respond_to do |format|
      if @monitored_url.save
        format.html { redirect_to @monitored_url, notice: "Monitored url was successfully created." }
        format.json { render :show, status: :created, location: @monitored_url }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @monitored_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /monitored_urls/1 or /monitored_urls/1.json
  def update
    respond_to do |format|
      if @monitored_url.update(monitored_url_params)
        format.html { redirect_to @monitored_url, notice: "Monitored url was successfully updated." }
        format.json { render :show, status: :ok, location: @monitored_url }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @monitored_url.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monitored_urls/1 or /monitored_urls/1.json
  def destroy
    @monitored_url.destroy!

    respond_to do |format|
      format.html { redirect_to monitored_urls_path, status: :see_other, notice: "Monitored url was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_monitored_url
      @monitored_url = current_user.monitored_urls.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def monitored_url_params
      params.require(:monitored_url).permit(:url, :name, :active)
    end
end
