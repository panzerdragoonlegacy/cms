class PagesController < ApplicationController
  before_action :load_page, except: [:index, :new, :create]

  def index
    if params[:drafts]
      @pages = policy_scope(Page.where(publish: false).order(:name).
        page(params[:page]))
    else
      @pages = policy_scope(Page.order(:name).page(params[:page]))
    end
  end

  def new
    @page = Page.new
    authorize @page
  end

  def create
    @page = Page.new(page_params)
    authorize @page
    if @page.save
      flash[:notice] = "Successfully created page."
      if params[:continue_editing]
        redirect_to edit_page_path(@page)
      else
        redirect_to @page
      end
    else
      render :new
    end
  end

  def update
    if @page.update_attributes(page_params)
      flash[:notice] = "Successfully updated page."
      if params[:continue_editing]
        redirect_to edit_page_path(@page)
      else
        redirect_to @page
      end
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to pages_path, notice: "Successfully destroyed page."
  end

  private

  def page_params
    params.require(:page).permit(
      :name,
      :content,
      :publish,
      illustrations_attributes: [:id, :illustration, :_destroy]
    )
  end

  def load_page
    @page = Page.find_by url: params[:id]
    authorize @page
  end
end
