class MessagesController < ApplicationController
  require "json"
  require "open-uri"

  require "json"
  require "open-uri"

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
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_message_container", partial: "messages/form",
                                                                            locals: { chat: @chat, message: @message })
        end
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

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

  # Transformer la réponse du LLM en Hash
  response_hash = JSON.parse(response.content)

    # Récupérer les films recommandés
    @movies = response_hash["movies"] || []

    # Appeler l'API pour chaque film
    movie_cards

    # Sauvegarder la réponse enrichie
    @response = Message.create!(
      role: "assistant",
      content: response_hash.to_json,
      chat: @chat
    )
  end

  def movie_cards
    @movies.each do |movie|
      title = URI.encode_www_form_component(movie["title"])
      year = movie["year"]
      api_url = "https://tmdb.lewagon.com/search/movie?query=#{title}&year=#{year}"
      serialized_response = URI.parse(api_url).read
      api_response = JSON.parse(serialized_response)
      movie_data = api_response["results"].first
      next unless movie_data

    if movie_data
      movie["poster_path"] = movie_data["poster_path"]
      movie["overview"] = movie_data["overview"]
      movie["vote_average"] = movie_data["vote_average"]
      movie["api_endpoint"] = movie_data["id"]
      movie["release_date"] = movie_data["release_date"]
    end
  end
end

# fonction movies, à ajouter : un button to dans la carte du résultat de la disscuss avec l'API
# à envoyer en parametre avec les données de mon movie en appelant la méthode create de movie
# movie à ajoute = un button to dans la carte du résultat de la disscuss avec l'API
# à envoyer en parametre avec les données de mon movie en appelant la méthode create de movie
