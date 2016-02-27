require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require 'net/http'
require 'json'
require 'flickraw'
require './models.rb'

FlickRaw.api_key = 'ca40a058e5ceb04e8b41514d758350b3'
FlickRaw.shared_secret = 'd1ad76b69c599de5'

get '/' do
    # 検索タグ
    word = "breakfast,food"
    
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
end