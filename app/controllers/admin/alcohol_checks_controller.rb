require 'csv'

class Admin::AlcoholChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @target_date = parse_date(params[:date])

    @alcohol_checks = AlcoholCheck.where(checked_on: @target_date).includes(:user, :checker).order(created_at: :desc)

    respond_to do |format|
      format.csv do
        send_data generate_csv(@alcohol_checks),
                  filename: "alcohol_checks_#{@target_date}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  private

  def parse_date(date)
    return Date.current if date.blank?

    Date.iso8601(date)
  rescue ArgumentError
    Date.current
  end

  def generate_csv(alcohol_checks)
    CSV.generate(headers: true) do |csv|
      csv << [
        "社員番号",
        "社員名",
        "日付",
        "チェック種別",
        "アルコール濃度",
        "確認者",
        "検知器使用",
        "記録時刻"
      ]

      alcohol_checks.each do |check|
        csv << [
          check.user.employee_number,
          check.user.name,
          check.checked_on.strftime("%Y/%m/%d"),
          check.arrival? ? "出社時" : "帰社時",
          check.alcohol_value,
          check.checker.name,
          check.used_detector? ? "使用" : "未使用",
          check.created_at.strftime("%H:%M")
        ]
      end
    end
  end

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "管理者権限が必要です"
    end
  end
end
