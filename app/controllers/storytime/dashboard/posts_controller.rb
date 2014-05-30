require_dependency "storytime/application_controller"

module Storytime
  module Dashboard
    class PostsController < DashboardController
      before_action :set_post, only: [:edit, :update, :destroy]
      before_action :load_posts
      before_action :load_media, only: [:new, :edit]
      
      respond_to :json, only: :destroy
      respond_to :html, only: :destroy

      def index
        authorize @posts
      end

      def new
        @post = current_user.storytime_posts.new
        authorize @post
      end

      def edit
        authorize @post
      end

      def create
        @post = current_user.storytime_posts.new(post_params)
        @post.draft_user_id = current_user.id
        authorize @post

        if @post.save
          redirect_to edit_dashboard_post_path(@post), notice: I18n.t('flash.posts.create.success')
        else
          load_media
          render :new
        end
      end

      def update
        authorize @post
        @post.draft_user_id = current_user.id
        if @post.update(post_params)
          redirect_to edit_dashboard_post_path(@post), notice: I18n.t('flash.posts.update.success')
        else
          load_media
          render :edit
        end
      end

      def destroy
        authorize @post
        @post.destroy
        flash[:notice] = I18n.t('flash.posts.destroy.success') unless request.xhr?
        respond_with [:dashboard, @post]
      end

      private
        def set_post
          @post = Post.find(params[:id])
        end

        def load_posts
          @posts = policy_scope(Storytime::Post).page(params[:page]).per(10)
        end

        def post_params
          params.require(:post).permit(*policy(@post || current_user.storytime_posts.new).permitted_attributes)
        end
    end
  end
end
