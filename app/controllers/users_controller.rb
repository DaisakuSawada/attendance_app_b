class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  before_action :ensure_correct_user, only: :show

  def index
    @users = query.order(:id).page(params[:page])
  end
  
  

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  def ensure_correct_user
    if
      current_user.admin?
    elsif
      current_user.id != params[:id].to_i
      flash[:danger] = "編集権限がありません。"
      redirect_to users_url
    end
  end

  def new
    @user = User.new
  end

  def create #新規ユーザー作成の処理
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy # ユーザーを削除する際の処理
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to @user
  end

  def edit_basic_info
    
  end
  
  
  def edit
    
  end
 
  def update_basic_info
    unless @user.update(works_params)
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to users_url and return
    else
      User.where(:id => 1..999).update(works_params)
      flash[:success] = "全ユーザーの基本情報を更新しました。"  
    end
    redirect_to users_url
  end
  
    
  private # strongparameterの設定

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end

    def works_params
      params.require(:user).permit(:id, :basic_time, :work_time)
    end
    
    def query
      if params[:user].present? && params[:user][:name]
        User.where('name LIKE ?', "%#{params[:user][:name]}%")
      else
        User.all
      end
    end
end