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
    date = Time.now
    mois = %w[janvier février mars avril mai juin juillet août septembre octobre novembre décembre][date.month - 1]
    @chat.title = "Ma recherche du #{date.strftime('%d')} #{mois} #{date.strftime('%Y à %H:%M')}"
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
      respond_to do |format|
        format.html { redirect_to chat_path(@chat) }
        format.turbo_stream
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    window.location.reload
  end

  private

  def chat_params
    params.require(:chat).permit(:title)
  end
end
