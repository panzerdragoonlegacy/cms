class Admin::SagasController < ApplicationController
  include LoadableForSaga
  layout 'admin'
  before_action :load_tags, except: [:index, :destroy]
  before_action :load_saga, except: [:index, :new, :create]

  def index
    @q = Saga.order(:sequence_number).ransack(params[:q])
    @sagas = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @saga = Saga.new
    authorize @saga
  end

  def create
    @saga = Saga.new saga_params
    authorize @saga
    if @saga.save
      flash[:notice] = 'Successfully created saga.'
      redirect_to_saga
    else
      render :new
    end
  end

  def update
    if @saga.update saga_params
      flash[:notice] = 'Successfully updated saga.'
      redirect_to_saga
    else
      render :edit
    end
  end

  def destroy
    @saga.destroy
    redirect_to admin_sagas_path, notice: 'Successfully destroyed saga.'
  end

  private

  def saga_params
    params.require(:saga).permit(
      :tag_id,
      :sequence_number,
      :name
    )
  end

  def redirect_to_saga
    if params[:continue_editing]
      redirect_to edit_admin_saga_path(@saga)
    else
      redirect_to top_level_page_path(@saga)
    end
  end
end
