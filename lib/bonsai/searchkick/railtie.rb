module Bonsai
  module Searchkick
    # Use Railties
    class Railtie < ::Rails::Railtie
      initializer 'setup_searchkick' do

        logger = ::Rails.logger
        url = ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL']

        begin
          # TODO: sanity check URL? If it starts with https:, it should end in :443
          if url && URI.parse(url)
            filtered_url = url.sub(/:[^:@]+@/, ':FILTERED@')
            logger.debug("Bonsai: Initializing default Searchkick client with #{filtered_url}")
            ENV['ELASTICSEARCH_URL'] = url
          else
            logger.debug('BONSAI_URL and ELASTICSEARCH_URL not present, proceeding with Searchkick default of http://localhost:9200.')
          end
        rescue URI::InvalidURIError => e
          logger.error("Elasticsearch cluster URL is invalid: #{e.message}")
        end
      end
    end
  end
end
