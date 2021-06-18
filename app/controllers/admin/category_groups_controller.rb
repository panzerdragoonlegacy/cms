class Admin::CategoryGroupsController < ApplicationController
  include LoadableForCategoryGroup
  layout 'admin'
  before_action :load_category_group, except: [:index, :new, :create]

  def index
    @q = CategoryGroup.order(:name).ransack(params[:q])
    @category_groups = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @category_group = CategoryGroup.new(
      category_group_type: params[:category_group_type]
    )
    authorize @category_group
  end

  def create
    @category_group = CategoryGroup.new category_group_params
    authorize @category_group
    if @category_group.save
      flash[:notice] = 'Successfully created category group.'
      redirect_to_category_group
    else
      render :new
    end
  end

  def update
    if @category_group.update category_group_params
      flash[:notice] = 'Successfully updated category group.'
      redirect_to_category_group
    else
      render :edit
    end
  end

  def destroy
    @category_group.destroy
    redirect_to(
      admin_category_groups_path,
      notice: 'Successfully destroyed category group.'
    )
  end

  private

  def category_group_params
    params.require(:category_group).permit(
      :name,
      :category_group_type
    )
  end

  def redirect_to_category_group
    if params[:continue_editing]
      redirect_to edit_admin_category_group_path(@category_group)
    else
      redirect_to admin_category_groups_path
    end
  end
end
