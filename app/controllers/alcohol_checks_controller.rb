class AlcoholChecksController < ApplicationController
  before_action :authenticate_user!

  def create
    @alcohol_check = AlcoholCheck.new(alcohol_check_params)
    @alcohol_check.user = current_user

    if @alcohol_check.save
      redirect_to root_path, notice: "アルコールチェックを登録しました"
    else
      prepare_dashboard

      if @alcohol_check.arrival?
        @arrival_form = @alcohol_check
      elsif @alcohol_check.departure?
        @departure_form = @alcohol_check
      end

      label = @alcohol_check.arrival? ? "出社時" : "帰社前"
      flash.now[:alert] = "#{label}のアルコールチェックに失敗しました: #{@alcohol_check.errors.full_messages.join("、")}"
      render "dashboard/index", status: :unprocessable_entity
    end
  end

  private

  def prepare_dashboard
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

  def alcohol_check_params
    params.require(:alcohol_check).permit(
      :check_type,
      :alcohol_value,
      :checker_id,
      :used_detector
    )
  end
end
