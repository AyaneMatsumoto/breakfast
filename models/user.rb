ActiveRecord::Base.establish_connection(
  ENV['DATABASE_URL']||'sqlite3:db/development.db')

class User < ActiveRecord::Base
end

class Like < ActiveRecord::Base
end