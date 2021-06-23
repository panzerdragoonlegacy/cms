module LoadableForTag
  extend ActiveSupport::Concern

  private

  def load_tag
    @tag = Tag.find_by url: params[:id]
    authorize @tag
  end

  def load_news_entries
    @news_entries = NewsEntryPolicy::Scope.new(
      current_user,
      NewsEntry.includes(:tags).where(tags: { name: @tag.name })
        .order('published_at desc').limit(50)
    ).resolve
  end

  def load_literature
    @works_of_literature = PagePolicy::Scope.new(
      current_user,
      Page.includes(:tags)
        .where(page_type: :literature.to_s, tags: { name: @tag.name })
        .order(:name)
    ).resolve
  end

  def load_pictures
    @pictures = PicturePolicy::Scope.new(
      current_user,
      Picture.includes(:tags)
        .where(tags: { name: @tag.name }).order(:name).limit(50)
    ).resolve
  end

  def load_music_tracks
    @music_tracks = MusicTrackPolicy::Scope.new(
      current_user,
      MusicTrack.includes(:tags).where(tags: { name: @tag.name }).order(:name)
    ).resolve
  end

  def load_videos
    @videos = VideoPolicy::Scope.new(
      current_user,
      Video.includes(:tags).where(tags: { name: @tag.name }).order(:name)
    ).resolve
  end

  def load_downloads
    @downloads = DownloadPolicy::Scope.new(
      current_user,
      Download.includes(:tags).where(tags: { name: @tag.name }).order(:name)
    ).resolve
  end

  def load_quizzes
    @quizzes = QuizPolicy::Scope.new(
      current_user,
      Quiz.includes(:tags).where(tags: { name: @tag.name }).order(:name)
    ).resolve
  end
end
