class Admin::CategoriesController < ApplicationController
  include LoadableForCategory
  layout 'admin'
  before_action :load_category_groups, except: [:index, :destroy]
  before_action :load_sagas, only: [:new, :edit]
  before_action :load_category, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = Category.order(:name).ransack(params[:q])
    @categories = policy_scope(
      @q.result.includes(:category_group).page(params[:page])
    )
  end

  def new
    @category = Category.new category_type: params[:category_type]
    authorize @category
  end

  def create
    @category = Category.new category_params
    authorize @category
    if @category.save
      flash[:notice] = 'Successfully created category.'
      redirect_to_category
    else
      render :new
    end
  end

  def update
    if @category.update category_params
      flash[:notice] = 'Successfully updated category.'
      redirect_to_category
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to(
      admin_categories_path,
      notice: 'Successfully destroyed category.'
    )
  end

  private

  def category_params
    params.require(:category).permit(
      policy(@category || :category).permitted_attributes
    )
  end

  def redirect_to_category
    if params[:continue_editing]
      redirect_to edit_admin_category_path(@category)
    else
      redirect_to @category
    end
  end
end
