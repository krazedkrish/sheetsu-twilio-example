require 'sheetsu'
require 'twilio-ruby'
require 'yaml'

secrets = YAML.load_file('./secrets.yml')
@twilio = Twilio::REST::Client.new(
  secrets['twilio_account_sid'], secrets['twilio_auth_token']
)
@from = secrets['twilio_phone_number']
@sheetsu = Sheetsu::Client.new(secrets['sheetsu_api_key'])

def msg_all_movies(to)
  movies = @sheetsu.read
  movies.map do |m|
    msg = "Movie title: #{m["name"]} \n" +
      "Release Date: #{m["date"]} \n" +
      "Description: #{m["description"]} \n\n"
    @twilio.account.messages.create({ from: @from, to: to, body: msg })
  end
end

def msg_movie(to, movie_name)
  movie = @sheetsu.read(search: { name: movie_name })
  msg = movie.map do |m|
    "Movie title: #{m["name"]}\n" +
      "Release Date: #{m["date"]}\n" +
      "Description: #{m["description"]}\n"
  end
  @twilio.account.messages.create({ from: @from, to: to, body: msg })
end

if ARGV.length == 0
 puts "Usage: ruby app.rb <phone_number> [Optional:<movie title>]"
elsif ARGV.length == 1
  to = ARGV[0]
  puts msg_all_movies(to)
else
  to = ARGV[0]
  movie_name = ARGV[1..-1].join(" ")
  puts msg_movie(to, movie_name)
end
