require 'openssl'
require 'openssl'
require 'Base64'
key = "key"
data = "message-to-be-authenticated"
mac = OpenSSL::HMAC.hexdigest("SHA256", key, data)
puts mac

hmac = OpenSSL::HMAC.hexdigest(mac, key, data)
puts hmac