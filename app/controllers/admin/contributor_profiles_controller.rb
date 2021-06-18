class Admin::ContributorProfilesController < ApplicationController
  include LoadableForContributorProfile
  layout 'admin'
  before_action :load_contributor_profile, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = ContributorProfile.order(:name).ransack(params[:q])
    @contributor_profiles = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @contributor_profile = ContributorProfile.new
    authorize @contributor_profile
  end

  def create
    @contributor_profile = ContributorProfile.new contributor_profile_params
    authorize @contributor_profile
    if @contributor_profile.save
      flash[:notice] = 'Successfully created contributor profile.'
      redirect_to_contributor_profile
    else
      render :new
    end
  end

  def update
    if @contributor_profile.update contributor_profile_params
      flash[:notice] = 'Successfully updated contributor profile.'
      redirect_to_contributor_profile
    else
      render :edit
    end
  end

  def destroy
    @contributor_profile.destroy
    redirect_to(
      admin_contributor_profiles_path,
      notice: 'Successfully destroyed contributor profile.'
    )
  end

  private

  def contributor_profile_params
    params.require(:contributor_profile).permit(
      policy(@contributor_profile || :contributor_profile).permitted_attributes
    )
  end

  def redirect_to_contributor_profile
    if params[:continue_editing]
      redirect_to edit_admin_contributor_profile_path(@contributor_profile)
    else
      redirect_to @contributor_profile
    end
  end
end
