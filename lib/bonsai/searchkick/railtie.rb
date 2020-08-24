# frozen_string_literal: true

module Bonsai
  module Searchkick
    # Use Railties
    class Railtie < ::Rails::Railtie
      # Create an initializer to set up the Searchkick client with the proper URL
      initializer 'setup_searchkick' do

        # Append a method to the String class so we can get a nice way to check
        # that a String is a valid URL. `_searchkick_` is part of the method
        # name to avoid possible collisions.
        String.class_eval do
          def is_valid_searchkick_url?
            uri = URI.parse self
            uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
          rescue URI::InvalidURIError
            false
          end
        end

        # Set the Searchkick BulkReindexJob concurrency
        class ::Searchkick::BulkReindexJob
          concurrency write_concurrency if defined?(ActiveJob::TrafficControl)

          def write_concurrency
            ENV.fetch('BULK_CONCURRENCY', 2)
          end
        end

        # Check the URL for a port.
        #
        # Returns
        #   * An Integer representing the port, or nil if no port is given.
        #
        def searchkick_port
          return nil unless @@url.is_valid_searchkick_url?

          port = @@url[/:([0-9]{0,5}$)/, 1]
          return port.to_i if port.present?
          nil
        end

        # Append a port to the URL string if necessary.
        #
        # The Elasticsearch-ruby gem that Searchkick uses introduced a bug into
        # its URL-parsing. Essentially, it will *always* assume port 9200,
        # regardless of the protocol used. In other words, if you initialize
        # the client with https://my-cluster.com, it will assume that you mean
        # https://my-cluster.com:9200 and not https://my-cluster.com:443 (the
        # standard port for HTTPS).
        #
        # This method will ensure the URL port is correctly called out when using
        # a Bonsai cluster.
        #
        # Returns
        #   * A String for the URL, possibly appended with a Bonsai-supported
        #     port.
        #
        def maybe_add_port
          if ENV['BONSAI_URL'].present?
            uri = URI.parse(@@url) rescue ''
            if uri.kind_of?(URI::HTTPS) || uri.kind_of?(URI::HTTP)
              port = (uri.kind_of?(URI::HTTPS)) ? 443 : 80
              if !@@port.present?
                log("Bonsai: Appending port #{port} to the cluster URL for production environment.")
                return "#{@@url}:#{port}".gsub('::', ':')
              elsif @@port != port
                log("Bonsai: Overriding the requested port #{@@port} with the standard #{port} for production environment.")
                return "#{@@url.rpartition(':').first}:#{port}"
              end
            end
          end
          @@url
        end

        # Modify the Searchkick defaults.
        #
        # Returns
        #   * A Hash of options for the Searchkick client
        def bonsai_options
          {
            transport_options: {
              headers: {
                user_agent: 'Bonsai Searchkick Client',
                'Keep-Alive': 'timeout=10, max=1000'
              },
            },
            accept_encoding: 'gzip'
          }
        end

        # The Redis gem is a runtime dependency of the Bonsai Searchkick gem, so
        # it should be available, but may not have been loaded yet. Try to load
        # it, but don't crash if there is a problem.
        def maybe_load_redis
          require 'redis'
        rescue Exception
          log("Could not load Redis!")
        end

        # The ActiveJob::TrafficControl library is a runtime dependency of the
        # Bonsai Searchkick gem, so it should be available, but may not have
        # been loaded yet. Try to load it, but don't crash if there is a
        # problem.
        def maybe_load_traffic_control
          require 'active_job/traffic_control'
        rescue Exception
          log("Could not load ActiveJob::TrafficControl!")
        end

        # The ActiveJob::TrafficControl library is a runtime dependency of the
        # Bonsai Searchkick gem, so it should be available, but may not have
        # been loaded yet. Try to load it, but don't crash if there is a
        # problem.
        def maybe_load_typhoeus
          require 'typhoeus'
        rescue Exception
          log("Could not load Typhoeus!")
        end

        # Filter out the credentials from the logs.
        #
        # This gem outputs some debug messages to indicate that it has
        # successfully loaded and initialized the correct cluster. Cluster URLs
        # can contain user credentials, which we do not want logged anywhere. This
        # method filters out the password from the URL and replaces it with an
        # anonymized value, making it safe to print.
        #
        # Returns
        #   * A String for the URL, with the credentials filtered for safe
        #     printing.
        #
        def filtered_url
          @@ported_url.sub(%r{//[\S+]{1,}:[\S+]{1,}@}, '//REDACTED@')
        end

        # Print a debug message to STDOUT. Muted when in a test environment.
        def log(message)
          @@logger.debug("[Bonsai]: #{message}") unless Rails.env.test?
        end

        @@logger = Logger.new(STDOUT)
        @@url = ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] || ''
        @@port = searchkick_port
        @@ported_url = maybe_add_port
        @@filtered_url = filtered_url

        if @@url.present? && @@url.is_a?(String) && @@url.is_valid_searchkick_url?
          log("Initializing default Searchkick client with #{@@filtered_url}")
          ENV['ELASTICSEARCH_URL'] = @@ported_url
        else
          log('Neither BONSAI_URL nor ELASTICSEARCH_URL are set in this environment.')
          log('Proceeding with Searchkick default of http://localhost:9200.')
        end

        maybe_load_redis
        maybe_load_traffic_control
        maybe_load_typhoeus

        # Override some Searchkick defaults
        log('Setting up HTTP Keep-Alive and GZIP compression.')
        ::Searchkick.remove_instance_variable(:@client) if Searchkick.instance_variable_get(:@client).present?
        ::Searchkick.client_options = bonsai_options
        log('Typhoeus found. Using libcurl like a boss.') if defined?(Typhoeus)
        if defined?(Redis)
          log('Redis found. Setting up indexing queue.')
          ::Searchkick.redis = ::Redis.new
          if defined?(ActiveJob::TrafficControl)
            ::ActiveJob::TrafficControl.client = ::Searchkick.redis
            log("TrafficControl found. Setting write concurrency to #{::Searchkick::BulkReindexJob.new.write_concurrency}.")
          end
        end
      end
    end
  end
end
