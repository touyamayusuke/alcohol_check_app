class AlcoholChecksController < ApplicationController
  before_action :authenticate_user!

  def create
    @alcohol_check = AlcoholCheck.new(alcohol_check_params)
    @alcohol_check.user = current_user

    if @alcohol_check.save
      redirect_to root_path, notice: "アルコールチェックを登録しました"
    else
      redirect_to root_path,
                  alert: @alcohol_check.errors.full_messages.join("、")
    end
  end

  private

  def alcohol_check_params
    params.require(:alcohol_check).permit(
      :check_type,
      :alcohol_value,
      :checker_id,
      :used_detector
    )
  end
end
