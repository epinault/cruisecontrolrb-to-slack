require 'cruisecontrolrb-to-slack'
require 'minitest/autorun'
require 'minitest/pride'

class MiniTest::Spec
  def load_data_file(filename)
    File.open(File.join(File.dirname(__FILE__), 'data', filename)).read
  end
end