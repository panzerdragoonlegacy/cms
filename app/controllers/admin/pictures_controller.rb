class Admin::PicturesController < ApplicationController
  include LoadableForAlbumable
  include LoadableForPicture
  layout 'admin'
  before_action :load_replaceable_pictures, except: [:index, :destroy]
  before_action :load_albums, except: [:index, :destroy]
  before_action :load_categories, except: [:show, :destroy]
  before_action :load_picture, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = Picture.order(:name).ransack(params[:q])
    @pictures = policy_scope(@q.result.includes(:category).page(params[:page]))
  end

  def new
    if params[:category]
      category = Category.find_by url: params[:category]
      raise 'Category not found.' unless category.present?
      @picture = Picture.new category: category
    else
      @picture = Picture.new
    end
    authorize @picture
  end

  def create
    make_current_user_a_contributor unless current_user.administrator?
    @picture = Picture.new picture_params
    authorize @picture
    if @picture.save
      flash[:notice] = 'Successfully created picture.'
      redirect_to_picture
    else
      render :new
    end
  end

  def update
    params[:picture][:contributor_profile_ids] ||= []
    make_current_user_a_contributor unless current_user.administrator?
    if @picture.update picture_params
      flash[:notice] = 'Successfully updated picture.'
      redirect_to_picture
    else
      render :edit
    end
  end

  def destroy
    @picture.destroy
    redirect_to admin_pictures_path, notice: 'Successfully destroyed picture.'
  end

  private

  def picture_params
    params.require(:picture).permit(
      policy(@picture || :picture).permitted_attributes
    )
  end

  def redirect_to_picture
    if params[:continue_editing]
      redirect_to edit_admin_picture_path(@picture)
    else
      redirect_to @picture
    end
  end

  def make_current_user_a_contributor
    unless current_user.contributor_profile_id.to_s.in?(
      params[:picture][:contributor_profile_ids]
    )
      params[:picture][:contributor_profile_ids] <<
        current_user.contributor_profile_id
    end
  end
end
