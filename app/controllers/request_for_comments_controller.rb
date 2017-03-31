class RequestForCommentsController < ApplicationController
  before_action :set_request_for_comment, only: [:show, :edit, :update, :destroy, :mark_as_solved]

  skip_after_action :verify_authorized

  def authorize!
    authorize(@request_for_comments || @request_for_comment)
  end
  private :authorize!

  # GET /request_for_comments
  # GET /request_for_comments.json
  def index
    @request_for_comments = RequestForComment.last_per_user(2).order('created_at DESC').paginate(page: params[:page])
    authorize!
  end

  def get_my_comment_requests
    @request_for_comments = RequestForComment.where(user_id: current_user.id).order('created_at DESC').paginate(page: params[:page])
    render 'index'
  end

  def mark_as_solved
    authorize!
    @request_for_comment.solved = true
    respond_to do |format|
      if @request_for_comment.save
        format.json { render :show, status: :ok, location: @request_for_comment }
      else
        format.json { render json: @request_for_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def submit

  end

  # GET /request_for_comments/1
  # GET /request_for_comments/1.json
  def show
    authorize!
  end

  # GET /request_for_comments/new
  def new
    @request_for_comment = RequestForComment.new
    authorize!
  end

  # GET /request_for_comments/1/edit
  def edit
  end

  # POST /request_for_comments
  # POST /request_for_comments.json
  def create
    @request_for_comment = RequestForComment.new(request_for_comment_params)
    respond_to do |format|
      if @request_for_comment.save
        format.json { render :show, status: :created, location: @request_for_comment }
      else
        format.html { render :new }
        format.json { render json: @request_for_comment.errors, status: :unprocessable_entity }
      end
    end
    authorize!
  end

  def create_comment_exercise
    old = UserExerciseFeedback.find_by(exercise_id: params[:exercise_id], user_id: current_user.id, user_type: current_user.class.name)
    if old
      old.delete
    end
    uef = UserExerciseFeedback.new(comment_params)

    if uef.save
      render(json: {success: "true"})
    else
      render(json: {success: "false"})
    end
  end

  # DELETE /request_for_comments/1
  # DELETE /request_for_comments/1.json
  def destroy
    @request_for_comment.destroy
    respond_to do |format|
      format.html { redirect_to request_for_comments_url, notice: 'Request for comment was successfully destroyed.' }
      format.json { head :no_content }
    end
    authorize!
  end

  def comment_params
    params.permit(:exercise_id, :feedback_text).merge(user_id: current_user.id, user_type: current_user.class.name)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request_for_comment
      @request_for_comment = RequestForComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_for_comment_params
      # we are using the current_user.id here, since internal users are not able to create comments. The external_user.id is a primary key and does not require the consumer_id to be unique.
      params.require(:request_for_comment).permit(:exercise_id, :file_id, :question, :requested_at, :solved, :submission_id).merge(user_id: current_user.id, user_type: current_user.class.name)
    end

end
