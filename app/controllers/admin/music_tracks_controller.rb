class Admin::MusicTracksController < ApplicationController
  include LoadableForMusicTrack
  layout 'admin'
  before_action :load_categories, except: [:show, :destroy]
  before_action :load_music_track, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = MusicTrack.order(:name).ransack(params[:q])
    @music_tracks = policy_scope(
      @q.result.includes(:category).page(params[:page])
    )
  end

  def new
    if params[:category]
      category = Category.find_by url: params[:category]
      raise 'Category not found.' unless category.present?
      @music_track = MusicTrack.new category: category
    else
      @music_track = MusicTrack.new
    end
    authorize @music_track
  end

  def create
    make_current_user_a_contributor unless current_user.administrator?
    @music_track = MusicTrack.new music_track_params
    authorize @music_track
    if @music_track.save
      flash[:notice] = 'Successfully created music track.'
      redirect_to_music_track
    else
      render :new
    end
  end

  def update
    params[:music_track][:contributor_profile_ids] ||= []
    make_current_user_a_contributor unless current_user.administrator?
    if @music_track.update music_track_params
      flash[:notice] = 'Successfully updated music track.'
      redirect_to_music_track
    else
      render :edit
    end
  end

  def destroy
    @music_track.destroy
    redirect_to(
      admin_music_tracks_path,
      notice: 'Successfully destroyed music track.'
    )
  end

  private

  def music_track_params
    params.require(:music_track).permit(
      policy(@music_track || :music_track).permitted_attributes
    )
  end

  def redirect_to_music_track
    if params[:continue_editing]
      redirect_to edit_admin_music_track_path(@music_track)
    else
      redirect_to @music_track
    end
  end

  def make_current_user_a_contributor
    unless current_user.contributor_profile_id.to_s.in?(
      params[:music_track][:contributor_profile_ids]
    )
      params[:music_track][:contributor_profile_ids] <<
        current_user.contributor_profile_id
    end
  end
end
