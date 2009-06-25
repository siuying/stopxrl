class Tweet
  include DataMapper::Resource
  property  :id,                Serial
  property  :from_user,         String,       :length => 50
  property  :to_user,           String,       :length => 50
  property  :created_at,        DateTime
  property  :profile_image_url, String,       :length => 256
  property  :text,              String,       :length => 140
  property  :twitter_id,        BigDecimal,   :unique_index => true
end