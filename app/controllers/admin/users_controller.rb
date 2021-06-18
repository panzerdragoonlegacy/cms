class Admin::UsersController < ApplicationController
  layout 'admin'
  before_action :load_contributor_profiles, except: [:show, :destroy]
  before_action :load_user, except: [:index, :new, :create]

  def index
    @q = User.order(:email).ransack(params[:q])
    @users = policy_scope(
      @q.result.includes(:contributor_profile).page(params[:page])
    )
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new user_params
    password = generate_and_assign_random_password
    authorize @user
    attempt_to_create_user password
  end

  def update
    if @user.update user_params
      flash[:notice] = 'Successfully updated user.'
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'Successfully destroyed user.'
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :contributor_profile_id,
      :administrator
    )
  end

  def load_contributor_profiles
    @contributor_profiles = ContributorProfilePolicy::Scope.new(
      current_user,
      ContributorProfile.order(:name)
    ).resolve
  end

  def load_user
    @user = User.find_by id: params[:id]
    authorize @user
  end

  def generate_and_assign_random_password
    random_password = SecureRandom.uuid
    @user.password = random_password
    random_password
  end

  def attempt_to_create_user(password)
    if @user.save
      flash[:notice] = 'Successfully created user. A confirmation email was ' \
        "sent to #{@user.email}. The random password #{password} was " \
        'generated which you can optionally provide to the user.'
      redirect_to admin_users_path
    else
      render :new
    end
  end
end
