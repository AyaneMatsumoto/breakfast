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
    @images_added = Image.limit(10)
    erb :index
end

post '/signup' do
    @user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation:params[:password_confirmation]
    )
    
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect '/'
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

post '/like' do
        Like.create({
            title: params[:title],
            url: params[:url],
            description: params[:description],
            tags: params[:tags],
            user_id: session[:user].to_s
        })
        redirect '/'
end

get '/mylikes' do
    @images = Like.where(:user_id => session[:user].to_s )
    erb :mylikes
end

post '/unlike' do
    Like.find(params[:id]).destroy
    redirect "/mylikes"
end

get '/map' do
    @images = Like.where(:user_id => session[:user].to_s)
        # パターン3: Likeとpositionを結合させたハッシュimages_with_positionの配列を作って利用する 
    @images_test = Like.where(:user_id => session[:user].to_s)
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
        image_with_position[:url] = image.url.to_s
        s = image.url.to_s
        puts image_with_position[:url];
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

get '/creater' do
    word = "icecream,geotagged"
    images = flickr.photos.search(tags: word,tag_mode: "all", sort: "date-posted-desc", per_page: 10)
    @images = images
    @images_added = Image.limit(10)
    erb :for_creater
end

post '/add' do
    Image.create({
        title: params[:title],
        url: params[:url],
        description: params[:description],
        tags: params[:tags]
    })
    redirect '/creater'    
end

post '/delete' do
    Image.find(params[:id]).destroy
    redirect '/creater'    
end

    # 検索タグ
 #   word = "geotagged"
    
#    images = flickr.photos.search(tags: word,tag_mode: "all", sort: "date-posted-desc", per_page: 10)
    
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
   # binding.pry
get '/test' do
    erb :test    
end
