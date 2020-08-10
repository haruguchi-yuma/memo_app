require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class Memo
  def self.connect_db
    settings = {dbname: ENV['DB_NAME'], password: ENV['DB_PASS']}
    PG.connect(settings)
  end

  def self.index
    connect_db.exec("select * from Memo;")
  end

  def self.show(id)
    connect_db.exec("select * from Memo where id = $1;",[id])
  end

  def self.post_memo(title, content)
    connect_db.exec("insert into Memo (title, content) values ($1, $2);",[title, content])
  end

  def self.delete_memo(id)
    connect_db.exec("delete from Memo where id = $1",[id])
  end

  def self.patch_memo(id, title, content)
    sql = <<~UPDATE
      UPDATE Memo
      SET title = $2,
          content = $3
      WHERE id = $1;
    UPDATE
    
    connect_db.exec(sql,[id,title,content])
  end
end

get '/' do
  @result = Memo.index

  erb :top
end

get '/new' do
  erb :new
end

get '/*' do
  @id = params[:splat]
  @result = Memo.show(*@id)
  
  erb :show
end

post '/memos' do
  @title = params[:title]
  @content = params[:content]
  Memo.post_memo(@title, @content)
  @result = Memo.index

  erb :top
end

delete '/*' do
  @id = params[:splat]
  Memo.delete_memo(*@id)
  
  redirect '/'
end

patch '/*/edit' do
  @id = params[:splat]
  @result = Memo.show(*@id)
  
  erb :edit
end

post '/*' do
  @id = params[:splat]
  @title = params[:title]
  @content = params[:content]
  Memo.patch_memo(*@id, @title, @content)
  
  redirect '/'
end