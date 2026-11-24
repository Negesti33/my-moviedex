class MessagesController < ApplicationController
  SYSTEM_PROMPT = "
    You are a Movie fan.\n\n
    I am a 55 year old woman who wants to have recommendations for movies to watch.\n\n
    I live in Paris and interested in movie theaters near my location as well as what is available in the next 5 days on television.\n\n
    Answer concisely in Markdown.
  "
  def create
    @chat = current_user.chats.find(params[:chat_id])

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
