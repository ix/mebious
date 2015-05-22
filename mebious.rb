require 'sinatra'
require 'builder'
require_relative 'models/posts'
require_relative 'models/bans'
require_relative 'utils/Mebious'

$config = "./config.json"
$posts  = Posts.new($config)
$bans   = Bans.new($config)

# Main page.
get ('/') {
  @posts = $posts.last(20)

  erb :index
}

# API - Recent Posts
get ('/posts') {
  content_type :json
  $posts.last(20).to_a.to_json
}

# API - Last n Posts
get ('/posts/:n') {
  content_type :json

  n = params[:n].to_i
  if (n > 100 or n < 1)
    redirect '/posts'
  end

  $posts.last(n).to_a.to_json
}

# API - Make post
post ('/posts') {
  ip = request.ip
  text = params["text"].strip

  if $posts.duplicate? text
    redirect '/'
  end

  if $bans.banned? ip
    redirect '/'
  end
  
  if !params.has_key? "text"
    redirect '/'    
  end

  if params["text"].empty?
    redirect '/'
  end

  $posts.add(text, ip)
  redirect '/'
}

# RSS Feed
get ('/rss') {
  @posts = $posts.last(20)
  builder :rss
}
