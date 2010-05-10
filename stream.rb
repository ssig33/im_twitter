def get_twitter_stream c, q
  begin
    while true
      uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        # Streaming APIはBasic認証のみ
        request.basic_auth(c["username"], c["password"])
        http.request(request) do |response|
          raise 'Response is not chuncked' unless response.chunked?
          response.read_body do |chunk|
            # 空行は無視する = JSON形式でのパースに失敗したら次へ
            status = JSON.parse(chunk) rescue next
            # 削除通知など、'text'パラメータを含まないものは無視して次へ
            next unless status['text']
            user = status['user']
            puts "#{user['screen_name']}: #{status['text']}"
            q.push status
          end
        end
      end
    end
  rescue => e
    p e
  end
end

def post_twitter q, c
  begin
    puts "Post Start"
    c_key = "OPkP3EGBA5pQY2GMLaVIA"
    c_secret = "a8BqD9kfB6UimNflKgrNP2mNwBMNQiAtyqRnouo8ns"
    consumer = OAuth::Consumer.new(
      c_key,
      c_secret,
      :site => 'http://twitter.com'
    )
    access_token = OAuth::AccessToken.new(
      consumer,
      c["oauth_key"],
      c["aouth_secret"]
    )
    access_token.post 'http://twitter.com/statuses/update.json', "status" => q
  rescue => e
    p e
  end
end
