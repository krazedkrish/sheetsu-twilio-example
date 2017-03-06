require 'sinatra'
require 'sheetsu'
require 'twilio-ruby'
require 'yaml'


def msg_movie(movie_name)
  secrets = YAML.load_file('./secrets.yml')
  @sheetsu = Sheetsu::Client.new(secrets['sheetsu_api_key'])
  movie = @sheetsu.read(search: { name: movie_name })
  movie.map do |m|
    "Movie title: #{m["name"]}\n" +
      "Release Date: #{m["date"]}\n" +
      "Description: #{m["description"]}\n"
  end
end

post '/sms' do
  movie_name = params['Body']

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message msg_movie(movie_name)
  end

  twiml.text
end
