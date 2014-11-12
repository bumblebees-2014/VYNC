get '/' do
  puts "get!"
  erb :index
end

get '/allusers' do
  content_type :json
  User.all.offset(params["since"]).to_json
end

get '/videomessages/:device_id/all' do
  content_type :json
  User.find_by(device_id: params[:device_id]).all_messages(params["since"].to_i).to_json
end

post '/upload' do
  puts "post!"
  # the incoming file
  tempfile = request.params["file"][:tempfile]
  # A random hex to use as a filename, shasum was not working...
  video_id = SecureRandom.hex + ".mov"
  puts video_id
  # Instantiate a new videomessage object
  newVid = VideoMessage.new(sender_id: params["sender"],
  recipient_id: params["recipient"], video_id: video_id)
  # If there was a replyId sent with this request use that,
  # otherwise assume it's the first video in a chain and set the reply_to_id
  # to its own id
  newVid.save!
  newVid.reply_to_id = params["replyToID"] || newVid.id
  newVid.save!
  # Upload to s3!
  $s3.buckets.first.objects.create(video_id, tempfile)
  # Notify the recipient of their new message
  notify(User.find(params["recipient"]).devicetoken, "You have a new video!")
  "Hey There Cowboy"
end

get '/download' do
  send_file $s3.buckets.first.objects[params["download"]].read, :type => :mov
end

post "/newuser" do
  puts params

  User.create(devicetoken: params[:devicetoken], device_id: params[:deviceId], username: params[:username])
  notify(params[:deviceToken], "Welcome to Chainer!")
  "Hey There Cowboy"
end
