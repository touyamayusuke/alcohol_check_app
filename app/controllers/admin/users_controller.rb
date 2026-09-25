class Admin::UsersController < Admin::BaseController

  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.order(:employee_number)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = ENV.fetch("INITIAL_USER_PASSWORD")

    if @user.save
      redirect_to admin_users_path, notice: "ユーザーを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "ユーザー情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:employee_number, :name, :role)
  end
end
