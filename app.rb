require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'pry'

require 'open-uri'
require 'net/http'
require 'json'
require 'flickraw'
require './models/user.rb'

enable :sessions

FlickRaw.api_key = 'ca40a058e5ceb04e8b41514d758350b3'
FlickRaw.shared_secret = 'd1ad76b69c599de5'

get '/' do
    session[:test]
    # 検索タグ
    word = "dinner,geotagged"
    
    images = flickr.photos.search(tags: word,tag_mode: "all", sort: "date-posted-desc", per_page: 10)
    
    # images.each do |image|
    #     info = flickr.photos.getInfo :photo_id => image.id, :secret => image.secret
    #     #sizes = flickr.photos.getSizes :photo_id => image.id
    #     #size_list = sizes.map{ |size| "(#{ size.width } : #{ size.height })"}.join(", ")
    #     posted = Time.at(info.dates.posted.to_i).to_s
    #     url = FlickRaw.url image
    #     tags = info.tags
    #     tag_list = tags.map{ |tag| "#{ tag }" }.join(", ")
    #     puts "【タイトル】" + image.title
    #     puts "【URL】" + url
    #     puts "【投稿者】"+ info.owner.username
    #     puts "【投稿日】: " + posted 
    #   # puts "【出力可能サイズ(横:縦)】" + size_list
    #     puts "【説明】" + info.description
    #     puts "【タグ】" + tag_list
    #     puts ""
    # end
   # @urls = []
    #images.each do |image|
     #   @urls.push(FlickRaw.url image)
    #
    #end
   # binding.pry
    @images = images
    @message = params[:message]
    erb :index
end
post '/register' do
    @users = User.all
    @message = 0
    @users.each do |user|
        puts user.name
        if user.name == params[:name] then
          @message = 1
        end
    end
    if @message != 1
        User.create({
         name: params[:name],
         password: ""       
        })
    end
    redirect '/?message='+@message.to_s
end

post '/like' do
        Like.create({
            title: params[:title],
            url: params[:url],
            description: params[:description],
            tags: params[:tags],
            user_id: "0"
        })
        redirect '/'
end

get '/mylikes' do
    @images = Like.where(:user_id => '0')
    erb :mylikes
end

post '/unlike' do
    Like.find(params[:id]).destroy
    redirect "/mylikes"
end

get '/map' do
    @images = Like.where(:user_id => '0')
    
    
    # パターン1: latsの配列とlonsの配列を作って利用する
    @images_test = Like.where(:user_id => '0')
    # user_idが0のレコードの配列を準備
    
    @lats = []
    # latを入れるための配列を準備
    @images_test.each{|image|
        rp = Regexp.new("geo:lat=")
        # 正規表現をするためのRegexpインスタンスを作成。
        rp =~ image.tags 
        # 文字列マッチング
        @lats << Regexp.last_match.post_match[0,8].to_f/1000000
        # 文字列がマッチした位置の後ろから9文字を取得してlat配列に代入
    }
    
    @lons = []
    # lonを入れるための配列を準備
    @images_test.each{|image|
        rp = Regexp.new("geo:lon=")
        # 正規表現をするためのRegexpインスタンスを作成。
        rp =~ image.tags 
        # 文字列マッチング
        @lons << Regexp.last_match.post_match[0,9].to_f/1000000
        # 文字列がマッチした位置の後ろから10文字を取得してlat配列に代入
        # latとlonで取得文字数が違うことに注意！
    }
    
    
    # パターン2: latとlonをキーに持つハッシュpositionを要素に持つpositionsの配列を作って利用する
    @images_test = Like.where(:user_id => '0')
    # user_idが0のレコードの配列を準備
    @positions = []
    @images_test.each{|image|
    
        position = {}
        # latをlonを格納するためのインスタンスハッシュpositionを準備
        rp = Regexp.new("geo:lat=")
        # 正規表現をするためのRegexpインスタンスを作成。
        rp =~ image.tags 
        # 文字列マッチング
        position[:lat] = Regexp.last_match.post_match[0,8].to_f/1000000
        # 文字列がマッチした位置の後ろから9文字を取得、ハッシュpositionのキー"lat"に代入。
        
        rp = Regexp.new("geo:lon=")
        # 正規表現をするためのRegexpインスタンスを作成。
        rp =~ image.tags 
        # 文字列マッチング
        position[:lon] = Regexp.last_match.post_match[0,9].to_f/1000000
        # 文字列がマッチした位置の後ろから10文字を取得、ハッシュpositionのキー"lon"に代入。
        # latとlonで取得文字数が違うことに注意！
        
        @positions << position
        # 配列positionsに作ったpositionを代入
    }
    
    
        # パターン3: Likeとpositionを結合させたハッシュimages_with_positionの配列を作って利用する 
    @images_test = Like.where(:user_id => '0')
    # user_idが0のレコードの配列を準備
    @images_with_position = []
    # Likeモデルのtitleとdescription、正規表現で求めたlat,lonをキーに持つハッシュimages_with_positionの配列を用意
    @images_test.each{|image|
    
        image_with_position = {}
        # latをlonを格納するためのインスタンスハッシュimage_with_positionを準備
        
        image_with_position[:title] = image.title.to_s
        # titleキーを追加し、titleを代入
        image_with_position[:description] = image.description.to_s
        # descriptionキーを追加し、descriptionを代入
        
        rp = Regexp.new("geo:lat=")
        # 正規表現をするためのRegexpインスタンスを作成。
        rp =~ image.tags 
        # 文字列マッチング
        image_with_position[:lat] = Regexp.last_match.post_match[0,8].to_f/1000000
        # 文字列がマッチした位置の後ろから9文字を取得、ハッシュpositionのキー"lat"に代入。
        
        rp = Regexp.new("geo:lon=")
        # 正規表現をするためのRegexpインスタンスを作成。
        rp =~ image.tags 
        # 文字列マッチング
        image_with_position[:lon] = Regexp.last_match.post_match[0,9].to_f/1000000
        # 文字列がマッチした位置の後ろから10文字を取得、ハッシュpositionのキー"lon"に代入。
        # latとlonで取得文字数が違うことに注意！

        @images_with_position << image_with_position
        
    }
    
    
    erb :map
    #s = parseInt(lat * 3600000.0) + ',' + parseInt(lon * 3600000.0);    
end
