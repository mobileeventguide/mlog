require 'test/unit'
require File.expand_path('../../lib/mlog', __FILE__)
require 'tempfile'

class TestMLog < Test::Unit::TestCase
  include MLog

  def setup
    @log_file = Tempfile.new 'mlog'
    MLog::Configuration.add_log_path :file, @log_file.path
  end

  def teardown
    @log_file.unlink
  end

  %w(error warn info debug).each do |log|
    define_method "test_#{log}_log" do
      message = "Logging an #{log} message!!"
      send :"#{log[0]}log", message
      assert @log_file.read.include? message
    end
  end
end
