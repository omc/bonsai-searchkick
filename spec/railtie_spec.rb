require 'rails' # will import the Rails code, if it's not already loaded.
require_relative '../lib/bonsai/searchkick/railtie'

describe Bonsai::Searchkick::Railtie do
  let(:initializer) do
    described_class.initializers.select{|i| i.name == 'setup_searchkick' }.first
  end

  let(:bonsai_url) { "https://user123:pass456@some-cluster.bonsai.io:443" }

  let(:cluster_url) { "http://127.0.0.1" }

  let(:client_url) { ENV['ELASTICSEARCH_URL'] }

  let(:simulate_rails_startup) { initializer.block.call }

  before do
    ENV['RAILS_ENV'] = 'test'
  end

  it 'has the right initializer' do
    expect(initializer).not_to be_nil
  end

  describe 'URL assignment' do
    before do
      ENV['BONSAI_URL'] = nil
      ENV['ELASTICSEARCH_URL'] = nil
    end

    context 'when no environment variable exists' do
      it 'defaults to whatever Searchkick wants' do
        simulate_rails_startup
        expect(client_url).to be_nil
      end
    end

    context 'when only the BONSAI_URL exists' do
      it 'sets the client to the Bonsai URL' do
        ENV['BONSAI_URL'] = bonsai_url
        simulate_rails_startup
        expect(client_url).to eql(bonsai_url)
      end
    end

    context 'when only the ELASTICSEARCH_URL exists' do
      it 'sets the client to the cluster URL' do
        ENV['ELASTICSEARCH_URL'] = cluster_url
        simulate_rails_startup
        expect(client_url).to eql(cluster_url)
      end
    end

    context 'when both BONSAI_URL and ELASTICSEARCH_URL exist' do
      it 'prefers the Bonsai URL' do
        ENV['BONSAI_URL'] = bonsai_url
        ENV['ELASTICSEARCH_URL'] = cluster_url
        simulate_rails_startup
        expect(client_url).to eql(bonsai_url)
      end
    end
  end

  describe 'port assignment' do
    before do
      ENV['BONSAI_URL'] = nil
      ENV['ELASTICSEARCH_URL'] = nil
    end

    context 'when the URL calls for the HTTP protocol' do
      context 'and standard port 80 is specified' do
        context 'and the BONSAI_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['BONSAI_URL'] = 'http://user123:pass456@something.io:80'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io:80')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['BONSAI_URL'] = 'http://something.io:80'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io:80')
            end
          end
        end

        context 'and only the ELASTICSEARCH_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://user123:pass456@something.io:80'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io:80')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://something.io:80'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io:80')
            end
          end
        end
      end

      context 'when a non-standard port is specified' do
        context 'and the BONSAI_URL is present' do
          context 'with authentication' do
            it 'sets the port to 80' do
              ENV['BONSAI_URL'] = 'http://user123:pass456@something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io:80')
            end
          end

          context 'without authentication' do
            it 'sets the port to 80' do
              ENV['BONSAI_URL'] = 'http://something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io:80')
            end
          end
        end

        context 'and only the ELASTICSEARCH_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://user123:pass456@something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io:123')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io:123')
            end
          end
        end
      end

      context 'when a port is not specified' do
        context 'and the BONSAI_URL is present' do
          context 'with authentication' do
            it 'sets the port to 80' do
              ENV['BONSAI_URL'] = 'http://user123:pass456@something.io'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io:80')
            end
          end

          context 'without authentication' do
            it 'sets the port to 80' do
              ENV['BONSAI_URL'] = 'http://something.io'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io:80')
            end
          end
        end

        context 'and only the ELASTICSEARCH_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://user123:pass456@something.io'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://something.io'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io')
            end
          end
        end
      end
    end

    context 'HTTPS protocol' do
      context 'and standard port 443 is specified' do
        context 'and the BONSAI_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['BONSAI_URL'] = 'https://user123:pass456@something.io:443'
              simulate_rails_startup
              expect(client_url).to eql('https://user123:pass456@something.io:443')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['BONSAI_URL'] = 'https://something.io:443'
              simulate_rails_startup
              expect(client_url).to eql('https://something.io:443')
            end
          end
        end

        context 'and only the ELASTICSEARCH_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'https://user123:pass456@something.io:443'
              simulate_rails_startup
              expect(client_url).to eql('https://user123:pass456@something.io:443')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'https://something.io:443'
              simulate_rails_startup
              expect(client_url).to eql('https://something.io:443')
            end
          end
        end
      end

      context 'when a non-standard port is specified' do
        context 'and the BONSAI_URL is present' do
          context 'with authentication' do
            it 'sets the port to 443' do
              ENV['BONSAI_URL'] = 'https://user123:pass456@something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('https://user123:pass456@something.io:443')
            end
          end

          context 'without authentication' do
            it 'sets the port to 443' do
              ENV['BONSAI_URL'] = 'https://something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('https://something.io:443')
            end
          end
        end

        context 'and only the ELASTICSEARCH_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'https://user123:pass456@something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('https://user123:pass456@something.io:123')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'https://something.io:123'
              simulate_rails_startup
              expect(client_url).to eql('https://something.io:123')
            end
          end
        end
      end

      context 'when a port is not specified' do
        context 'and the BONSAI_URL is present' do
          context 'with authentication' do
            it 'sets the port to 443' do
              ENV['BONSAI_URL'] = 'https://user123:pass456@something.io'
              simulate_rails_startup
              expect(client_url).to eql('https://user123:pass456@something.io:443')
            end
          end

          context 'without authentication' do
            it 'sets the port to 443' do
              ENV['BONSAI_URL'] = 'https://something.io'
              simulate_rails_startup
              expect(client_url).to eql('https://something.io:443')
            end
          end
        end

        context 'and only the ELASTICSEARCH_URL is present' do
          context 'with authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://user123:pass456@something.io'
              simulate_rails_startup
              expect(client_url).to eql('http://user123:pass456@something.io')
            end
          end

          context 'without authentication' do
            it 'does not change the URL' do
              ENV['ELASTICSEARCH_URL'] = 'http://something.io'
              simulate_rails_startup
              expect(client_url).to eql('http://something.io')
            end
          end
        end
      end
    end
  end

  describe 'malformed URLs' do
    before do
      ENV['BONSAI_URL'] = nil
      ENV['ELASTICSEARCH_URL'] = nil
    end

    context 'in the BONSAI_URL variable' do
      context 'when auth is' do
        context 'missing the username' do
          it 'is fine' do
            ENV['BONSAI_URL'] = 'https://:pass456@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://:pass456@something.com:443')
          end
        end

        context 'missing the password' do
          it 'is fine' do
            ENV['BONSAI_URL'] = 'https://user123:@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://user123:@something.com:443')
          end
        end

        context 'missing both credentials' do
          it 'is fine' do
            ENV['BONSAI_URL'] = 'https://:@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://:@something.com:443')
          end
        end

        context 'missing everything' do
          it 'is fine' do
            ENV['BONSAI_URL'] = 'https://@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://@something.com:443')
          end
        end
      end

      context 'when port is' do
        context 'implied but not specified' do
          it 'is fine' do
            ENV['BONSAI_URL'] = 'https://user123:pass456@something.com:'
            simulate_rails_startup
            expect(client_url).to eql('https://user123:pass456@something.com:443')
          end
        end

        context 'specified multiple times somehow' do
          it 'let Searchkick deal with it' do
            ENV['BONSAI_URL'] = 'https://user123:pass456@something.com:80:443'
            simulate_rails_startup
            expect(client_url).to be_nil
          end
        end

        context 'not a number' do
          it 'let Searchkick deal with it' do
            ENV['BONSAI_URL'] = 'https://user123:pass456@something.com:eighty'
            simulate_rails_startup
            expect(client_url).to be_nil
          end
        end
      end

      context 'when the user is a literal monkey at a keyboard' do
        it 'let Searchkick deal with it' do
          ENV['BONSAI_URL'] = 'httpq:\\something.com@user123:pass456'
          simulate_rails_startup
          expect(client_url).to be_nil
        end
      end
    end

    context 'in the ELASTICSEARCH_URL variable' do
      context 'when auth is' do
        context 'missing the username' do
          it 'is fine' do
            ENV['ELASTICSEARCH_URL'] = 'https://:pass456@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://:pass456@something.com')
          end
        end

        context 'missing the password' do
          it 'is fine' do
            ENV['ELASTICSEARCH_URL'] = 'https://user123:@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://user123:@something.com')
          end
        end

        context 'missing both credentials' do
          it 'is fine' do
            ENV['ELASTICSEARCH_URL'] = 'https://:@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://:@something.com')
          end
        end

        context 'missing everything' do
          it 'is fine' do
            ENV['ELASTICSEARCH_URL'] = 'https://@something.com'
            simulate_rails_startup
            expect(client_url).to eql('https://@something.com')
          end
        end
      end

      context 'when port is' do
        context 'implied but not specified' do
          it 'is fine' do
            ENV['ELASTICSEARCH_URL'] = 'https://user123:pass456@something.com:'
            simulate_rails_startup
            expect(client_url).to eql('https://user123:pass456@something.com:')
          end
        end

        context 'specified multiple times somehow' do
          it 'let Searchkick deal with it' do
            ENV['ELASTICSEARCH_URL'] = 'https://user123:pass456@something.com:80:443'
            simulate_rails_startup
            expect(client_url).to eql('https://user123:pass456@something.com:80:443')
          end
        end

        context 'not a number' do
          it 'let Searchkick deal with it' do
            ENV['ELASTICSEARCH_URL'] = 'https://user123:pass456@something.com:eighty'
            simulate_rails_startup
            expect(client_url).to eql('https://user123:pass456@something.com:eighty')
          end
        end
      end

      context 'when the user is a literal monkey at a keyboard' do
        it 'let Searchkick deal with it' do
          ENV['ELASTICSEARCH_URL'] = 'httpq:\\something.com@user123:pass456'
          simulate_rails_startup
          expect(client_url).to eql('httpq:\\something.com@user123:pass456')
        end
      end
    end
  end
end
