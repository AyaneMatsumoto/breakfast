ActiveRecord::Base.establish_connection(
  ENV['DATABASE_URL']||'sqlite3:db/development.db')

class User < ActiveRecord::Base
    has_secure_password
    validates :password,
        length: {in: 5..10}
end

class Like < ActiveRecord::Base
end

class Image < ActiveRecord::Base
end