class AttachmentsController < ApplicationController

  #def index
    #@project = current_user.projects.find(params[:project_id])
    #@story = @project.stories.find(params[:story_id])
    #@notes = @story.notes
    #render :json => @notes
  #end

  #def show
    #@project = current_user.projects.find(params[:project_id])
    #@story = @project.stories.find(params[:story_id])
    #@note = @story.notes.find(params[:id])
    #render :json => @note
  #end

  #def destroy
    #@project = current_user.projects.find(params[:project_id])
    #@story = @project.stories.find(params[:story_id])
    #@note = @story.notes.find(params[:id])
    #@note.destroy
    #head :ok
  #end

  def create
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:story_id])
    @attachment = @story.attachments.build(params[:attachment])
    @attachment.user = current_user
    if @attachment.save
      render :json => @attachment
    else
      render :json => @attachment, :status => :unprocessable_entity
    end
  end
end

