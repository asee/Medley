require 'rubygems'
require 'sinatra'
require 'rack/cache'
require 'combo_handler'

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'file:/var/cache/rack/meta',
  :entitystore => 'file:/var/cache/rack/body',
  :default_ttl => 86400,
  :allow_reload => false,
  :allow_revalidate => false

run ComboHandler