# frozen_string_literal: true

require 'json'
require 'ssrf_filter'
require 'kramdown'
require 'twingly/url/utilities'
require 'uri'

module BountyTargets
  class Intigriti
    STATUSES = %w[pending open closed suspended]
    TYPES = %w[invalid public vetted invitationOnly responsibleDisclosure registered internal confidential]

    def scan
      return @scan_results if instance_variable_defined?(:@scan_results)

      @scan_results = directory_index.map do |program|
        program.merge(program_scopes(program))
      end.sort_by do |program|
        program[:name]
      end
    end

    def uris
      scan.flat_map do |program|
        program[:targets][:in_scope]
      end.select do |scope|
        scope[:type] == 'web'
      end.map do |scope|
        scope[:target]
      end
    end

    private

    def directory_index
      programs = ::JSON.parse(SsrfFilter.get(::URI.parse('https://api-public.intigriti.com/api/project')).body)
      programs.map do |program|
        id = ::URI.escape(program['companyHandle']) + '/' + ::URI.escape(program['projectHandle'])
        {
          id: id,
          name: program['name'],
          url: 'https://www.intigriti.com/public/project/' + id,
          status: STATUSES[program['status']],
          type: TYPES[program['type']]
        }
      end
    end

    def program_scopes(program)
      uri = ::URI.parse('https://api-public.intigriti.com/api/project/' + program[:id])
      response = ::JSON.parse(SsrfFilter.get(uri).body) rescue {}

      in_scope = scopes_to_hashes(response['domains']) + scopes_to_hashes(response['inScope']).uniq do |scope|
        scope[:target]
      end
      {
        targets: {
          in_scope: in_scope,
          out_of_scope: scopes_to_hashes(response['outScope'])
        }
      }
    end

    def scopes_to_hashes(scopes)
      parser = ::URI::RFC2396_Parser.new
      Array(scopes).flat_map do |scope|
        markdown = Kramdown::Document.new(scope['content'].to_s).to_html
        Twingly::URL::Utilities.extract_valid_urls(markdown).map(&:to_s)
      end.uniq.map do |target|
        {
          type: 'web',
          target: target,
        }
      end
    end
  end
end
