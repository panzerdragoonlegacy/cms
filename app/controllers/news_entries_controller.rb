class NewsEntriesController < ApplicationController
  include LoadableForNewsEntry
  before_action :load_news_entry, except: [:index, :new, :create]

  def index
    if params[:contributor_profile_id]
      load_contributors_news_entries
    elsif params[:filter] == 'draft'
      load_draft_news_entries
    else
      @news_entries = policy_scope(
        NewsEntry.order('published_at desc').page(params[:page])
      )
    end
  end

  def new
    @news_entry = NewsEntry.new
    authorize @news_entry
  end

  def create
    @news_entry = NewsEntry.new news_entry_params
    make_current_user_the_contributor
    authorize @news_entry
    if @news_entry.save
      flash[:notice] = 'Successfully created news entry.'
      redirect_to_news_entry
    else
      render :new
    end
  end

  def update
    if @news_entry.update_attributes news_entry_params
      flash[:notice] = 'Successfully updated news entry.'
      redirect_to_news_entry
    else
      render :edit
    end
  end

  def destroy
    @news_entry.destroy
    redirect_to news_entries_path, notice: 'Successfully destroyed news entry.'
  end

  private

  def news_entry_params
    params.require(:news_entry).permit(
      policy(@news_entry || :news_entry).permitted_attributes
    )
  end

  def redirect_to_news_entry
    if params[:continue_editing]
      redirect_to edit_news_entry_path(@news_entry)
    else
      redirect_to @news_entry
    end
  end

  def make_current_user_the_contributor
    return if current_user.administrator?
    unless current_user.contributor_profile == @news_entry.contributor_profile
      @news_entry.contributor_profile_id = current_user.contributor_profile_id
    end
  end
end
