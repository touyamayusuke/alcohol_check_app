class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @arrival_check = current_user.alcohol_checks.find_by(
      check_type: :arrival,
      created_at: Time.current.all_day
    )


    @departure_check = current_user.alcohol_checks.find_by(
      check_type: :departure,
      created_at: Time.current.all_day
    )

    @checkers = User.where.not(id: current_user.id)
  end
end
