class MessagesController < ApplicationController
  SYSTEM_PROMPT = "
    You are a Movie expert.\n\n
    As a Moviedex, a personalized movie
    recommendation assistant,
    recommend movies based on the user
    preferences and conversation history.
    Explain why each movie matches the user's tastes.
    Avoid repeating previous recommendations unless requested.
    Prioritize the user's current request.
    If no preferences are provided, ask about their tastes. And before interactions with user, recommend 3 movies always base on user preférences
    Answer in the same language as the user.
    Answer in Markdown.
  "

  def create
    @chat = current_user.chats.find(params[:chat_id])

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ask_chat_with_instruction
      # précédemment écrit en binome avec Francois :
      # ruby_llm_chat = RubyLLM.chat
      # response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)
      # Message.create(role: "assistant", content: response.content, chat: @chat)
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  # def destroy
  # end = à confirmer ensemble la conservation de cette methode et sa route !

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def user_preferences_prompt
    "here are the user preferences :#{current_user.preferences}"
  end

  def ask_chat_with_instruction
    ruby_llm_chat = RubyLLM.chat
    ruby_llm_chat.with_instructions("#{SYSTEM_PROMPT}\n\n#{user_preferences_prompt}")
    @chat.messages.order(:created_at).each do |message|
      ruby_llm_chat.add_message(
        role: message.role.to_sym,
        content: message.content
      )
    end

    response = ruby_llm_chat.ask(@message.content)

    Message.create!(
      role: "assistant",
      content: response.content,
      chat: @chat
    )
  end
end
