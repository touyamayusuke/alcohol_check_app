class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @target_date = parse_date(params[:date])
    @users = User.all
  end

  private

  def parse_date(date)
    return Date.current if date.blank?

    Date.iso8601(date)
  rescue ArgumentError
    Date.current
  end

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "管理者権限が必要です"
    end
  end
end
