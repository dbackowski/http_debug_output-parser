# frozen_string_literal: true

require_relative 'parser/version'
require 'json'

module HttpDebugOutput
  class Parser
    def initialize(debug_output)
      @debug_output = debug_output.split("\n")
    end

    def call
      {
        request: parse_request,
        response: parse_response
      }
    end

    private

    def parse_request # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      request_lines = @debug_output[find_range_for_start_and_end_strings('<- ', '-> ')]
                      .map { |line| clean_line(line.gsub('<- ', '')) }
      method, path, protocol = request_lines.first.split
      headers = request_lines[1..].take_while { |line| line != '' }
      payload = request_lines[headers.count + 1..].join

      {
        method:,
        path:,
        protocol:,
        headers:,
        payload: payload.empty? ? nil : JSON.parse(payload)
      }
    end

    def parse_response # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      response_lines = @debug_output[find_range_for_start_and_end_strings('-> ', 'read ')]
                       .map { |line| clean_line(line.gsub('-> ', '')) }
                       .filter { |line| line != '' }
      protocol, status, *message = response_lines.first.split
      headers = response_lines[1..].take_while { |line| !line.start_with?('reading') }
      payload = response_lines[headers.count + 2..].join

      {
        protocol:,
        status:,
        message: message.join(' '),
        headers:,
        payload: payload.empty? ? nil : JSON.parse(payload)
      }
    end

    def find_range_for_start_and_end_strings(start_index_string, end_index_string)
      start_index = @debug_output.find_index { |line| line.start_with?(start_index_string) }
      end_index = @debug_output.find_index { |line| line.start_with?(end_index_string) }
      start_index..end_index - 1
    end

    def clean_line(line)
      line.gsub("\r", '').gsub(/\A"/, '').gsub(/"\Z/, '')
    end
  end
end
