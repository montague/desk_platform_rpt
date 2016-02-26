$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'desk_platform_rpt'
require 'byebug'

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end
