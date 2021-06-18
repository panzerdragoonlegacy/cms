class Admin::NewsEntriesController < ApplicationController
  include LoadableForNewsEntry
  layout 'admin'
  before_action :load_news_entry, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = NewsEntry.order(created_at: :desc).ransack(params[:q])
    @news_entries = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @news_entry = NewsEntry.new
    authorize @news_entry
  end

  def create
    make_current_user_the_contributor
    @news_entry = NewsEntry.new news_entry_params
    authorize @news_entry
    if @news_entry.save
      flash[:notice] = 'Successfully created news entry.'
      redirect_to_news_entry
    else
      render :new
    end
  end

  def update
    params[:news_entry][:contributor_profile_ids] ||= []
    if @news_entry.update news_entry_params
      flash[:notice] = 'Successfully updated news entry.'
      redirect_to_news_entry
    else
      render :edit
    end
  end

  def destroy
    @news_entry.destroy
    redirect_to(
      admin_news_entries_path,
      notice: 'Successfully destroyed news entry.'
    )
  end

  private

  def news_entry_params
    params.require(:news_entry).permit(
      policy(@news_entry || :news_entry).permitted_attributes
    )
  end

  def redirect_to_news_entry
    if params[:continue_editing]
      redirect_to edit_admin_news_entry_path(@news_entry)
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
