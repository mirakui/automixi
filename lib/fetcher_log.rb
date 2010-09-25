require 'mongo_mapper'

class FetcherLog
  include MongoMapper::Document

  connection Mongo::Connection.new('localhost')
  set_database_name "automixi_#{ApplicationConfig.env}"

  key :name, String
  key :last_id, String
end
