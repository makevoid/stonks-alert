require "yaml"
require "json"
require "bundler"
Bundler.require :default

PATH = File.expand_path __FILE__, "../"

R = Redis.new

DEBUG_DEFAULT = false
DEBUG = ENV["DEBUG"] == "1" || DEBUG_DEFAULT

class Redis
  alias :[]  :get
  alias :[]= :set
end

sms_recipients_path = File.expand_path "~/.stonks_sms_recipients"
sms_recipients_default = File.read(sms_recipients_path).strip if File.exists? sms_recipients_path

twilio_number_path = File.expand_path "~/.twilio_number"
twilio_number_default = File.read(twilio_number_path).strip if File.exists? twilio_number_path

key_stonks_path = "~/.alphavantage-stonks-key"
key_stonks_path = File.expand_path key_stonks_path
key_stonks_default = File.read(key_stonks_path).strip if File.exists? key_stonks_path

twilio_keys_path = File.expand_path "~/.twilio_keys"
twilio_keys_default = File.read(twilio_keys_path).strip if File.exists? twilio_keys_path

sms_recipients = ENV["SMS_RECIPIENTS"] || sms_recipients_default
sms_recipients = sms_recipients.split "|"
SMS_RECIPIENTS = sms_recipients

KEY_STONKS_API = ENV["ALPHA_VANTAGE_KEY"] || key_stonks_default

TWILIO_NUMBER = ENV["TWILIO_NUMBER"] || twilio_number_default
twilio_keys = ENV["TWILIO_KEYS"] || twilio_keys_default
twilio_keys = twilio_keys.split "|"
TWILIO_SID, TWILIO_TOKEN = twilio_keys

# NOTE: optimization possible (batching all calls in consecutive minutes, then waiting for longer)
# MINUTE_REQUEST_LIMIT = 5
# MINUTE_REQUEST_LIMIT_DELAY = 60 / MINUTE_REQUEST_LIMIT + 1 # 12 seconds
seconds_in_a_day = 86400
DAILY_REQUEST_LIMIT  = 500
DAILY_REQUEST_LIMIT_DELAY  = (seconds_in_a_day / DAILY_REQUEST_LIMIT).ceil + 1 # 174 seconds


require_relative '../lib/sms'

require_relative "../config/stonks"
require_relative "monkeypatches"
require_relative "alphavantage"
require_relative "stonks_api"
require_relative "cache_lib"
require_relative "utils"

include StonksAPI
include CacheLib
include Utils

# TODO: test redis properly
# begin
#   R["test"]
# rescue ExceptionName
#
# end
R["test"]
