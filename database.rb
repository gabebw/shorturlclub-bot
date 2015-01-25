require "./database_table_creator"

# A facade around the bot's Sequel instance.
class Database
  APPS_TABLE_NAME = :apps
  FAILURES_TABLE_NAME = :failures

  def initialize(sequel)
    @sequel = sequel
  end

  def ensure_tables_exist
    DatabaseTableCreator.new(
      @sequel,
      APPS_TABLE_NAME,
      FAILURES_TABLE_NAME
    ).create
  end

  def has_app?(username)
    @sequel[APPS_TABLE_NAME].first(twitter_username: username) != nil
  end

  def url_for(username)
    @sequel[APPS_TABLE_NAME].first(twitter_username: username).fetch(:full_domain)
  end

  def log_failure(username, response)
    @sequel[FAILURES_TABLE_NAME].insert(
      twitter_username: username,
      response_text: response.body,
      response_code: response.code,
      created_at: Time.now,
    )
  end

  def log_success(username, full_domain)
    @sequel[APPS_TABLE_NAME].insert(
      twitter_username: username,
      full_domain: full_domain,
      created_at: Time.now,
    )
  end
end
