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
          @@ported_url.sub(/:[^:@@]+@@/, ':FILTERED@@')
        end

        # Print a debug message to STDOUT. Muted when in a test environment.
        def log(message)
          @@logger.debug(message) unless Rails.env.test?
        end

        @@logger = Logger.new(STDOUT)
        @@url = ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] || ''
        @@port = searchkick_port
        @@ported_url = maybe_add_port
        @@filtered_url = filtered_url

        if @@url.present? && @@url.is_a?(String) && @@url.is_valid_searchkick_url?
          log("Bonsai: Initializing default Searchkick client with #{@@filtered_url}")
          ENV['ELASTICSEARCH_URL'] = @@ported_url
        else
          log('Bonsai: Neither BONSAI_URL nor ELASTICSEARCH_URL are set in this environment.')
          log('Bonsai: Proceeding with Searchkick default of http://localhost:9200.')
        end
      end
    end
  end
end
