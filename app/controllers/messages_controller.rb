class MessagesController < ApplicationController
  SYSTEM_PROMPT = "
   Vous êtes un expert en cinéma.
    En tant que Moviedex, un assistant personnalisé
    de recommandation de films. Répond en fonction des
    préférences de l'utilisateur.
    Repond en format JSON.
    Si je demande des recommandations explicitement alors donne 3 films maximum sous forme d'objet Javascript
    (avec les cles title, et year).
    Met ces films dans un array, associé à la clé movies.
    En plus des films, donne une réponse concise pour poursuivre l'échange.
    Associe cette réponse à la clé answer.
    Sinon donne un réponse à la question de l'utilisateur en format markdown,
    associé à la clé answer.
    Expliquez pourquoi chaque film correspond aux goûts de l'utilisateur.
    Évitez de répéter les recommandations précédentes, sauf si l'utilisateur le demande.
    Donnez la priorité à la demande actuelle de l'utilisateur.
    Si aucune préférence n'est indiquée, interrogez-le sur ses goûts.
    Lorsque l'utilisateur demande : Trouve-moi mon prochain film,
    propose trois films différents selon ses préférences :

    - Un film actuellement à l'affiche au cinéma.
    - Un film prochainement diffusé à la télévision française.
    - Un film disponible sur une plateforme de streaming.

    Pour chaque film, ajoute les clés suivantes :
    - category : cinema, television ou streaming.
    - provider : chaîne de télévision ou plateforme.
    - availability : information de disponibilité.
    - reason : raison de la recommandation.

    N'invente aucune information de disponibilité.
    Si une disponibilité ne peut pas être vérifiée, précise-le.
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

  @chat.messages.where.not(id: @message.id).order(:created_at).each do |message|
    ruby_llm_chat.add_message(
      role: message.role.to_sym,
      content: message.content
    )
  end

  response = ruby_llm_chat.ask(@message.content)

  # Je transforme response.content en un hash
  response_hash = JSON.parse(response.content)

  # Je récupère les films recommandés
  @movies = response_hash["movies"] || []

  # Je sauvegarde uniquement la réponse textuelle du LLM
  Message.create!(
    role: "assistant",
    content: response_hash["answer"],
    chat: @chat
  )
  # assistant_message.movies << saved_movie
  #  vérifier avant les associations avant d'intégrer la ligne précédente
  end
end

#   def ask_chat_with_instruction
#     ruby_llm_chat = RubyLLM.chat
#     ruby_llm_chat.with_instructions("#{SYSTEM_PROMPT}\n\n#{user_preferences_prompt}")
#     @chat.messages.order(:created_at).each do |message|
#       ruby_llm_chat.add_message(
#         role: message.role.to_sym,
#         content: message.content
#       )
#     end

#     response = ruby_llm_chat.ask(@message.content)
#     # je transforme response.content en un hash
#     # si la réponse contient la clé movies, alors je vais sauvegarder les movies en DB
#     # j'affiche les movies dans le chat + la réponse du LLM
#     # sinon on affiche seulement la réponse du llm en markdown
#     Message.create!(
#       role: "assistant",
#       content: response.content, # il faut remplacer le response.content par le nom_du_hash [:answer]
#       chat: @chat
#     )
#   end
# end
