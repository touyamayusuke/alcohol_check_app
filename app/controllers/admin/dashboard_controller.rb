class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.all
    @todays_checks = AlcoholCheck.where(created_at: Time.current.all_day).includes(:checker)
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "管理者権限が必要です"
    end
  end
end
