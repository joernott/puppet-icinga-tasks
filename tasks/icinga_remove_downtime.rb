#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true
require 'net/http'
require 'openssl'
require 'json'

def post(url, endpoint, user,pass, downtime)
  uri = URI.parse(url+endpoint)
  host=uri.host
  port=uri.port
  http = Net::HTTP.new(host, port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Post.new(uri.request_uri)
  request['Accept']='application/json'
  request.basic_auth(user, pass) if user != ''
  request.body=downtime.to_json
  response = http.request(request)
  JSON.parse(response.body)
end

def parse_env
  d = ENV.fetch('PT_downtime','')
  f = ENV.fetch('PT_filter','')
  t = ENV.fetch('PT_type','')
  a =ENV.fetch('PT_author','')
  downtime = {}
  downtime[:downtime] = d unless d == ''
  downtime[:filter] = f unless f == ''
  downtime[:type] = t unless t == ''
  downtime[:author] = a unless a == ''

  if downtime[:downtime] == ''
    if downtime[:filter] == '' or downtime [:type] == ''
      puts 'You must either provide a downtime or a type/filter definition.'
      exit 1
    end
  end
  downtime
end

hostname = %x(hostname -f)
url = "https://#{hostname}:5665/v1"
user = ENV.fetch('PT_user','puppet')
pass = File.open('/etc/icinga2/puppet.password').read.strip
downtime = parse_env
result = post(url, "/actions/remove-downtime", user, pass, downtime)
pp result
exit 0
