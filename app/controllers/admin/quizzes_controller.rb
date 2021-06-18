class Admin::QuizzesController < ApplicationController
  include LoadableForQuiz
  layout 'admin'
  before_action :load_quiz, except: [:index, :new, :create]

  def index
    clean_publish_false_param
    @q = Quiz.order(:name).ransack(params[:q])
    @quizzes = policy_scope(@q.result.page(params[:page]))
  end

  def new
    @quiz = Quiz.new
    authorize @quiz
  end

  def create
    make_current_user_a_contributor unless current_user.administrator?
    @quiz = Quiz.new quiz_params
    authorize @quiz
    if @quiz.save
      flash[:notice] = 'Successfully created quiz.'
      redirect_to_quiz
    else
      render :new
    end
  end

  def update
    params[:quiz][:contributor_profile_ids] ||= []
    make_current_user_a_contributor unless current_user.administrator?
    if @quiz.update quiz_params
      flash[:notice] = 'Successfully updated quiz.'
      redirect_to_quiz
    else
      render :edit
    end
  end

  def destroy
    @quiz.destroy
    redirect_to admin_quizzes_path, notice: 'Successfully destroyed quiz.'
  end

  private

  def quiz_params
    params.require(:quiz).permit(
      policy(@quiz || :quiz).permitted_attributes
    )
  end

  def redirect_to_quiz
    if params[:continue_editing]
      redirect_to edit_admin_quiz_path(@quiz)
    else
      redirect_to @quiz
    end
  end
  
  def make_current_user_a_contributor
    unless current_user.contributor_profile_id.to_s.in?(
      params[:quiz][:contributor_profile_ids]
    )
      params[:quiz][:contributor_profile_ids] <<
        current_user.contributor_profile_id
    end
  end
end
