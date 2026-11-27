class ChatsController < ApplicationController
  def index
    @chats = Chat.all.where(user: current_user)
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end

  def create
    @chat = Chat.new
    @chat.user = current_user
    @chat.title = "Ma recherche du #{Time.now.strftime('%d %B %Y à %H:%M')}"
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @chat = current_user.chats.find(params[:id])
    @chat.title = chat_params[:title]
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to chats_path
  end

  private

  def chat_params
    params.require(:chat).permit(:title)
  end
end
