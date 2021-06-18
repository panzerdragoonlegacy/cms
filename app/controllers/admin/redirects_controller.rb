class Admin::RedirectsController < ApplicationController
  include LoadableForRedirect
  layout 'admin'
  before_action :load_redirect, except: [:index, :new, :create]

  def index
    @q = Redirect.order(created_at: :desc).ransack(params[:q])
    @redirects = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @redirect = Redirect.new
    authorize @redirect
  end

  def create
    @redirect = Redirect.new redirect_params
    authorize @redirect
    if @redirect.save
      flash[:notice] = 'Successfully created redirect.'
      redirect_to_redirect
    else
      render :new
    end
  end

  def update
    if @redirect.update redirect_params
      flash[:notice] = 'Successfully updated redirect.'
      redirect_to_redirect
    else
      render :edit
    end
  end

  def destroy
    @redirect.destroy
    redirect_to(
      admin_redirects_path,
      notice: 'Successfully destroyed redirect.'
    )
  end

  private

  def redirect_params
    params.require(:redirect).permit(
      policy(@redirect || :redirect).permitted_attributes
    )
  end

  def redirect_to_redirect
    if params[:continue_editing]
      redirect_to edit_admin_redirect_path(@redirect)
    else
      redirect_to admin_redirects_path
    end
  end
end
