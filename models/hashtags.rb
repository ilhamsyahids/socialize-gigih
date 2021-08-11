require_relative '../db/db_connector.rb'

class Hashtags
  attr_accessor :content, :counter, :updated_at

  def initialize(params = {})
    @content = params[:content]
    @counter = params[:counter]
    @updated_at = params[:updated_at]
  end

  def save
    return false unless valid?

    client = create_db_client
    client.query("INSERT INTO hashtags (content, counter) VALUES ('#{content}', 1)")
    true
  end

  def add_counter
    return false unless valid?

    client = create_db_client
    client.query("UPDATE hashtags SET counter = counter + 1 WHERE content = '#{content}'")
    true
  end

  def min_counter
    return false unless valid?

    client = create_db_client
    client.query("UPDATE hashtags SET counter = counter - 1 WHERE content = '#{content}'")
    true
  end

  def reset_counter
    return false unless valid?

    client = create_db_client
    client.query("UPDATE hashtags SET counter = 1 WHERE content = '#{content}'")
    true
  end

  def self.find_by_content(content)
    client = create_db_client
    result = client.query("SELECT * FROM hashtags WHERE content = '#{content}'")
    convert_sql_result_to_array(result)[0]
  end

  def self.trending(limit = 5)
    client = create_db_client
    result = client.query("SELECT * FROM hashtags WHERE counter > 1 AND updated_at >= NOW() - INTERVAL 1 DAY ORDER BY counter DESC, updated_at DESC LIMIT #{limit}")
    convert_sql_result_to_array(result)
  end

  def valid?
    return false if @content.nil?
    return false if @content.length < 2
    return false if @content[0] != '#'
    true
  end

  def self.convert_sql_result_to_array(result)
    data = []
    result.each do |row|
      data << Hashtags.new({
        content: row["content"],
        counter: row["counter"],
        updated_at: row["updated_at"]
      })
    end if !result.nil? && result.size > 0
    data
  end
end
