class ProblemsController < ApplicationController

    before_action :require_login, only: [:new, :create, :add_comment]
    before_action :set_problem, only: [:show, :comments, :add_comment, :tests, :add_hints, :add_tests]
    before_action :require_creator_privilege, only: [:new, :create]

    # GET /problems/
    def index
        @categories = Category.all.sort_by!{ |l| l.name.downcase }
        @default_category = @categories.shift
    end

    # GET /problems/new
    def new
        @code_problem = CodeProblem.new
        @design_problem = DesignProblem.new
    end

    # POST /problems/
    def create
        @problem = Problem.new(problem_params)
        @problem.author = @current_user
        @category = Category.find_by_id(Integer(problem_params[:category_id]))

        if @problem.save
            respond_to do |format|
                format.html {redirect_to problems_url}
                format.js
            end
        else
            #Recreate form variables
            if @problem.is_code_problem?
                @code_problem = @problem
                @design_problem = DesignProblem.new
            else
                @design_problem = @problem
                @code_problem = CodeProblem.new
            end
            render 'new'
        end
    end



    # GET /problems/1
    # Get and organize comments if problem is a design problem
    def show
        @attempt = current_user.get_attempt(@problem) if current_user
        if @problem.is_design_problem?
            @top_comment = @problem.best_comment
            @comments = @problem.get_comments.keep_if { |c| c.id != @top_comment.id }
        end
    end

    # GET /problems/1/comments
    # Send organized comments to Handlebars template
    def comments
        if @problem.is_design_problem? and !@problem.comments.empty?
            resp = @problem.get_comments_pretty(current_user)
            render text: resp.to_json
        else
            render nothing: true
        end
    end

    # POST /problems/1/comments
    # Create new comment and update comments listing
    def add_comment
        if @problem.is_design_problem?
            @comment = Comment.new(comment_params)
            @comment.author = current_user
            if (@problem.comments << @comment)
                @resp = @problem.get_comments_pretty(current_user).to_json
                respond_to do |format|
                    format.js
                end
            else
                render nothing: true
            end
        end
    end

    # GET /problem/1/tests
    def tests
        if @problem.is_code_problem?
            render text: @problem.get_all_tests_info.to_json
        else
            # Raise a 404; only code problems should have tests
            raise ActionController::RoutingError.new('Not Found')
        end
    end

     # POST /problem/1/hints
    def add_hints
        @hints = Hint.save_hints(@problem, ActiveSupport::JSON.decode(params[:hints]))
    end

    # POST /problem/1/tests
    def add_tests
        @tests = Test.save_tests(@problem, ActiveSupport::JSON.decode(params[:tests]))
    end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_problem
            @problem = Problem.find_by_id(params[:id])
            raise ActionController::RoutingError.new('Not Found') unless @problem
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def problem_params
            params.require(:problem).permit(:type, :title, :question, :difficulty,
                                         :skeleton, :solution, :category_id, :tests_attributes => [:input, :correct_output])
        end

        def comment_params
            params.require(:comment).permit(:content, :design_problem_id)
        end

        def require_creator_privilege
            redirect_to :back, notice: "Lacks access to creating problems" unless @current_user.is_admin? or @current_user.is_content_creator?
            rescue ActionController::RedirectBackError
                lacks_back
        end

end
