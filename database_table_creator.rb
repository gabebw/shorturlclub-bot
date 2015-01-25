class DatabaseTableCreator
  def initialize(sequel, apps_table_name, failures_table_name)
    @sequel = sequel
    @apps_table_name = apps_table_name
    @failures_table_name = failures_table_name
  end


  def create
    unless sequel.tables.include?(apps_table_name)
      sequel.create_table apps_table_name do
        primary_key :id, type: Bignum

        String :twitter_username
        String :full_domain, text: true

        DateTime :created_at
      end
    end

    unless sequel.tables.include?(failures_table_name)
      sequel.create_table failures_table_name do
        primary_key :id, type: Bignum

        String :twitter_username
        String :response_text, text: true
        Integer :response_code

        DateTime :created_at
      end
    end
  end

  private

  attr_reader :sequel, :apps_table_name, :failures_table_name
end
