# For foreman
$stdout.sync = true

require "bundler/setup"
Bundler.require
Dotenv.load

require "chatterbot/dsl"
require "./deployer"
require "./database"

consumer_key ENV.fetch("CONSUMER_KEY")
consumer_secret ENV.fetch("CONSUMER_SECRET")
secret ENV.fetch("SECRET")
token ENV.fetch("TOKEN")

no_update false
verbose true

# List of users to ignore
blacklist ENV.fetch("BLACKLISTED_USERS", "").split(",")

# List of things to exclude from searches
exclude ["http://"]

database = Database.new(bot.db)
database.ensure_tables_exist

deployer = Deployer.new

streaming do
  replies do |tweet|
    username = from_user(tweet)

    unless database.has_app?(username)
      response = deployer.deploy(username)

      if response.code == 201
        external_url = JSON.parse(response.body)["url"]
        database.log_success(username, external_url)
        reply "#USER# Woo! You're in the short URL club! Your URL shortener will be up in about 5 min at #{external_url}", tweet
      else
        database.log_failure(username, response)
        reply "#USER# Oops! Something went wrong! Tweet at me to try again?", tweet
      end
    end
  end

  # Explicitly update the last tweet our script saw
  update_config
end
