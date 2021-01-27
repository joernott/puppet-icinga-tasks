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
  s = ENV.fetch('PT_start','now')
  start_time = %x(date -d "#{s}" +"%s").to_i
  e = ENV.fetch('PT_end','60 minutes')
  end_time = %x(date -d "#{e}" +"%s").to_i
  fixed = ENV.fetch('PT_fixed','false').to_s.downcase == 'true'
  all_services = ENV.fetch('PT_all_services','false').to_s.downcase == 'true'
  trigger_name = ENV.fetch('PT_trigger_name','')
  downtime = {
    type: ENV.fetch('PT_type',''),
    filter: ENV.fetch('PT_filter',''),
    author: ENV.fetch('PT_author',''),
    comment: ENV.fetch('PT_comment',''),
    start_time: start_time,
    end_time: end_time,
    fixed: fixed,
    child_options: ENV.fetch('PT_child_options','DowntimeNoChildren'),
  }
  downtime[:duration] = ENV.fetch('PT_duration','3600').to_i unless downtime[:fixed]
  downtime[:all_services] = all_services if downtime[:type] == 'Host'
  downtime[:trigger_name] = trigger_name unless trigger_name == ''
  if downtime[:filter] == ''
    puts 'You must provide a filter.'
    exit 1
  end
  if downtime[:author] == ''
    puts 'You must provide an author.'
    exit 1
  end
  if downtime[:comment] == ''
    puts 'You must provide a comment.'
    exit 1
  end
  if downtime[:start_time] == 0 or downtime[:end_time] == 0
    puts 'You must provide a start and end timestamp for the downtime.'
    exit 1
  end
  if downtime[:start_time] > downtime[:end_time]
    puts 'I am not a Tardis. Start time must be before end time.'
    exit 1
  end
  if downtime[:end_time] <= Time.now.to_i
    puts 'I am not a Tardis. The end of the downtime lies in the past.'
    exit 1
  end
  downtime
end

hostname = %x(hostname -f)
url = "https://#{hostname}:5665/v1"
user = ENV.fetch('PT_user','puppet')
pass = File.open('/etc/icinga2/puppet.password').read.strip
downtime = parse_env
result = post(url, '/actions/schedule-downtime', user, pass, downtime)
pp result
exit 0
