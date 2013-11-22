require 'typhoeus'
require 'json'
require 'open-uri'
require 'uri'

class Firebase
  class Request

    class << self

      def get(path, uri = Firebase.base_uri, auth = Firebase.auth)
        process(:get, path, uri, auth)
      end

      def put(path, value, uri = Firebase.base_uri, auth = Firebase.auth)
        process(:put, path, uri, auth, :body => value.to_json)
      end

      def post(path, value, uri = Firebase.base_uri, auth = Firebase.auth)
        process(:post, path, uri, auth, :body => value.to_json)
      end

      def delete(path, uri = Firebase.base_uri, auth = Firebase.auth)
        process(:delete, path, uri, auth)
      end

      def patch(path, value, uri = Firebase.base_uri, auth = Firebase.auth)
        process(:patch, path, uri, auth, :body => value.to_json)
      end

      def build_url(path, host = Firebase.base_uri, auth = Firebase.auth)
        path = "#{path}.json"
        query_string = auth ? "?auth=#{auth}" : ""
        url = URI.join(host, path, query_string)

        url.to_s
      end

      private

      def process(method, path, uri, auth, options={})
        raise "Please set the base uri before making requests" unless uri

	      @@hydra ||= Typhoeus::Hydra.new
        request = Typhoeus::Request.new(build_url(path, uri, auth),
                                        :body => options[:body],
                                        :method => method)
        @@hydra.queue(request)
        @@hydra.run

        new request.response
      end

    end

    attr_accessor :response

    def initialize(response)
      @response = response
    end

    def body
      JSON.parse(response.body, :quirks_mode => true)
    rescue JSON::ParserError => e
      response.body == 'null' ? nil : raise
    end

    def raw_body
      response.body
    end

    def success?
      [200, 204].include? response.code
    end

    def code
      response.code
    end

  end
end
