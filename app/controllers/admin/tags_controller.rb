class Admin::TagsController < ApplicationController
  include LoadableForTag
  layout 'admin'
  before_action :load_tag, except: [:index, :new, :create]

  def index
    @q = Tag.order(:name).ransack(params[:q])
    @tags = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @tag = Tag.new
    authorize @tag
  end

  def create
    @tag = Tag.new tag_params
    authorize @tag
    if @tag.save
      flash[:notice] = 'Successfully created tag.'
      redirect_to_tag
    else
      render :new
    end
  end

  def update
    if @tag.update tag_params
      flash[:notice] = 'Successfully updated tag.'
      redirect_to_tag
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to(
      admin_tags_path,
      notice: 'Successfully destroyed tag.'
    )
  end

  private

  def tag_params
    params.require(:tag).permit(
      policy(@tag || :tag).permitted_attributes
    )
  end

  def redirect_to_tag
    if params[:continue_editing]
      redirect_to edit_admin_tag_path(@tag)
    else
      redirect_to tag_path(@tag)
    end
  end
end
