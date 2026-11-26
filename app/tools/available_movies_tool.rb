require 'open-uri'

class AvailableMoviesTool < RubyLLM::Tool
  description "Gets available movies nearby and now."

  def execute
    apicinema_api_key = ENV.fetch("APICINEMA_API_KEY", nil)
    url = URI.parse("https://api.api-cinema.com/v1/showtimes/search")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url.path)
    request["Authorization"] = "Bearer #{apicinema_api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      near: { lat: current_user.latitude, lng: current_user.longitude, radiusKm: current_user.radius_km },
      from: "2026-09-25T18:00",
      to: "2026-09-25T23:59",
      version: "VOST",
      include: ["movie", "cinema"],
      limit: 100
    }.to_json

    response = http.request(request)
    data = JSON.parse(response.body)["data"]

    data.each do |s|
      puts "#{s['startsAt'][11, 5]} #{s['movie']['title']} — #{s['cinema']['name']} #{s['cinema']['distanceKm']} km"
    end

  # en cas de plantage de la méthode
  # retourne une erreur si l'appel API échoue
  # qui permet au LLM d'avertir l'utilisateur et lui expliquer l'erreur
  rescue StandardError => e
    { error: e.message }
  end
end
