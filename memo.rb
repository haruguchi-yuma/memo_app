require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require "date"

get '/' do
  @json_data = File.open("views/memo.json") do |file|
    JSON.load(file)
  end
  erb :top
end

get '/new' do
  erb :new
end

get '/show/*' do
  @id = params[:splat]
  @json_data = File.open("views/memo.json") do |file|
    JSON.load(file)
  end
  erb :show
end

post '/create' do
  @title = params[:title]
  @content = params[:content]
  @date = Date.today
  
  @json_data = File.open("views/memo.json") do |file|
    JSON.load(file)
  end
  
  id = SecureRandom.uuid
  add_data = {"#{id}" => {"title" => @title, "content" => @content, "date" => @date.strftime("%Y年 %m月 %d日")}} 
  @json_data["memo"] << add_data 

  File.open("views/memo.json", "w") do |file| 
    JSON.dump(@json_data, file) 
  end 

  erb :top
end

delete '/delete/*' do
  @id = params[:splat]
  @json_data = File.open("views/memo.json") do |file|
    JSON.load(file)
  end

  @json_data["memo"].delete_if do |memo|
    memo.include?(@id[0])
  end

  File.open("views/memo.json", "w") do |file|
    JSON.dump(@json_data, file)
  end

  redirect '/'
end

patch '/*/edit' do
  @id = params[:splat]
  @json_data = File.open("views/memo.json") do |file|
    JSON.load(file)
  end
  erb :edit
end

post '/*' do
  # ファイルの読み書き処理
  @id = params[:splat]
  @title = params[:title]
  @content = params[:content]
  @date = Date.today

  patch_data = {"title" => @title, "content" => @content , "date" => @date.strftime("%Y年 %m月 %d日")}

  @json_data = File.open("views/memo.json") do |file|
    JSON.load(file)
  end

  @json_data["memo"].each do |memo|
    if memo.include?(@id[0])
      memo[@id[0]] = patch_data
    end
    memo
  end

  File.open("views/memo.json", "w") do |file|
    JSON.dump(@json_data, file)
  end

  redirect '/'
end