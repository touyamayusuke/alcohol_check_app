class Admin::DashboardController < Admin::BaseController
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
end
