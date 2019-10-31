require 'minitest/autorun'
require 'bonsai/searchkick/railtie'

class RailtieTest < Minitest::Test
  def test_url
    assert_equal "",
      Railtie.url(ENV['BONSAI_URL'])
  end
end
