class Admin::AlbumsController < ApplicationController
  layout 'admin'
  include LoadableForAlbum

  before_action :load_picture_categories, except: [:index, :destroy]
  before_action :load_video_categories, except: [:index, :destroy]
  before_action :load_album, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = Album.order(:name).ransack(params[:q])
    @albums = policy_scope(@q.result.page(params[:page]))
  end

  def new
    if params[:category]
      category = Category.find_by url: params[:category]
      raise 'Category not found.' unless category.present?
      @album = Album.new category: category
    else
      @album = Album.new
    end
    authorize @album
  end

  def create
    the_params = synchronised_params album_params
    @album = Album.new the_params
    authorize @album
    if @album.save
      flash[:notice] = 'Successfully created album.'
      redirect_to_album
    else
      render :new
    end
  end

  def update
    params[:album][:contributor_profile_ids] ||= []
    params[:album][:tag_ids] ||= []
    the_params = synchronised_params album_params
    if @album.update the_params
      flash[:notice] = 'Successfully updated album.'
      redirect_to_album
    else
      render :edit
    end
  end

  def destroy
    @album.destroy
    redirect_to admin_albums_path, notice: 'Successfully destroyed album.'
  end

  private

  def album_params
    params.require(:album).permit(policy(@album || :album).permitted_attributes)
  end

  def synchronised_params(the_params)
    if the_params['pictures_attributes']
      the_params['pictures_attributes'].each do |key, value|
        the_params['pictures_attributes'][key]['category_id'] =
          the_params['category_id']
        if value['instagram_post_id'].blank?
          the_params['pictures_attributes'][key]['instagram_post_id'] =
            the_params['instagram_post_id']
        end
      end
      the_params = synchronise_attributes(the_params, 'pictures_attributes')
    end
    if the_params['videos_attributes']
      the_params = synchronise_attributes(the_params, 'videos_attributes')
    end
    the_params
  end

  def synchronise_attributes(the_params, attributes_key)
    the_params[attributes_key].each do |key, value|
      if value['source_url'].blank?
        the_params[attributes_key][key]['source_url'] =
          the_params['source_url']
      end
      if value['name'].blank?
        the_params[attributes_key][key]['name'] =
          the_params['name']
      end
      if value['description'].blank?
        the_params[attributes_key][key]['description'] =
          the_params['description']
      end
      if value['information'].blank?
        the_params[attributes_key][key]['information'] =
          the_params['information']
      end
      if value['contributor_profile_ids'].reject { |cp| cp.blank? }.blank?
        the_params[attributes_key][key]['contributor_profile_ids'] =
          the_params['contributor_profile_ids'].reject { |cp| cp.blank? }
      end
      if value['tag_ids'].reject { |t| t.blank? }.blank?
        the_params[attributes_key][key]['tag_ids'] =
          the_params['tag_ids'].reject { |t| t.blank? }
      end
    end
    the_params
  end

  def redirect_to_album
    if params[:continue_editing]
      redirect_to edit_admin_album_path(@album)
    elsif @album.pictures && @album.pictures.count > 0
      redirect_to @album.ordered_pictures.first
    elsif @album.videos && @album.videos.count > 0
      redirect_to @album.ordered_videos.first
    else
      redirect_to admin_albums_path
    end
  end
end
