require 'uri'
require 'net/http'
require 'json'

namespace :developers do
  desc "Fetch developer company details using ProxyCurl API"
  task fetch_developer_linkedin_company: :environment do
    begin
      api_endpoint = 'https://nubela.co/proxycurl/api/v2/linkedin'
      api_key = Rails.application.credentials.proxycurl_api_key
      header_dic = {'Authorization' => 'Bearer ' + api_key}
      params = {
        'url' => 'https://www.linkedin.com/in/johnrmarty/',
        'fallback_to_cache' => 'on-error',
        'use_cache' => 'if-present'
      }
      
      uri = URI(api_endpoint)
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      header_dic.each { |key, value| request[key] = value }

      response = http.request(request)

      # Check if the response was successful
      if response.code.to_i == 200
        # Process the response here
        #puts response.body
        response_hash = JSON.parse(response.body)
        begin
          # Attempt to access the first company name in the experiences array
          company_name = response_hash["experiences"][0]["company"]
        rescue NoMethodError
          # Handle the case where the experiences array or company field doesn't exist
          company_name = nil
        end
        puts company_name
      else
        # Handle the error here
        puts "Error: #{response.code} - #{response.message}"
      end
    rescue StandardError => e
      # Handle the exception here
      puts "Exception occurred: #{e.message}"
    end
  end
end
