class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @arrival_check = current_user.alcohol_checks.find_by(
      check_type: :arrival,
      checked_on: Date.current
    )


    @departure_check = current_user.alcohol_checks.find_by(
      check_type: :departure,
      checked_on: Date.current
    )

    @arrival_form = AlcoholCheck.new(check_type: :arrival)
    @departure_form = AlcoholCheck.new(check_type: :departure)

    @checkers = User.where.not(id: current_user.id)
  end
end
