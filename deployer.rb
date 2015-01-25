class Deployer
  include HTTParty

  PATH = "/api/apps"

  base_uri ENV.fetch("SHORTHANDED_URL")

  def initialize
    @headers = {
      "Accept" => "application/vnd.shorthanded+json; version=1",
      "X-App-Secret" => ENV.fetch("HEADER_SECRET"),
    }
  end

  def deploy(twitter_username)
    self.class.post(
      PATH,
      body: body_for(twitter_username),
      headers: @headers
    )
  end

  private

  def body_for(twitter_username)
    {
      app: {
        subdomain: twitter_username
      }
    }
  end
end
