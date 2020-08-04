require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require "date"

class JsonFile
  def self.json_to_hash
    File.open("views/memo.json") do |file|
      JSON.load(file)
    end
  end

  def self.hash_to_json(hash)
    File.open("views/memo.json", "w") do |file| 
      JSON.dump(hash, file) 
    end
  end
end

get '/' do
  @json_data = JsonFile.json_to_hash
  erb :top
end

get '/new' do
  erb :new
end

get '/show/*' do
  @id = params[:splat]
  @json_data = JsonFile.json_to_hash
  erb :show
end

post '/create' do
  @title = params[:title]
  @content = params[:content]
  @date = Date.today
  
  @json_data = JsonFile.json_to_hash
  
  id = SecureRandom.uuid
  add_data = {"#{id}" => {"title" => @title, "content" => @content, "date" => @date.strftime("%Y年 %m月 %d日")}} 
  @json_data["memo"] << add_data 
  
  JsonFile.hash_to_json(@json_data)
  
  erb :top
end

delete '/delete/*' do
  @id = params[:splat]
  @json_data = JsonFile.json_to_hash

  @json_data["memo"].delete_if do |memo|
    memo.include?(@id[0])
  end

  JsonFile.hash_to_json(@json_data)

  redirect '/'
end

patch '/*/edit' do
  @id = params[:splat]
  @json_data = JsonFile.json_to_hash
  erb :edit
end

post '/*' do
  # ファイルの読み書き処理
  @id = params[:splat]
  @title = params[:title]
  @content = params[:content]
  @date = Date.today

  patch_data = {"title" => @title, "content" => @content , "date" => @date.strftime("%Y年 %m月 %d日")}

  @json_data = JsonFile.json_to_hash

  @json_data["memo"].each do |memo|
    if memo.include?(@id[0])
      memo[@id[0]] = patch_data
    end
    memo
  end

  JsonFile.hash_to_json(@json_data)

  redirect '/'
end