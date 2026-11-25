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
    @chat.title = "none"
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    window.location.reload
  end
end
