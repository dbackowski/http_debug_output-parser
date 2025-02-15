# HttpDebugOutput::Parser

`HttpDebugOutput::Parser` is a Ruby gem designed to parse and transform the debug output from Ruby's Net::HTTP library into a structured, easy-to-read hash. This gem is particularly useful for developers who need to analyze HTTP requests and responses in a more human-readable and programmatically accessible format.

### Features

* Parses Debug Output: Converts raw Net::HTTP debug output into a structured Hash.

* Request and Response Details: Extracts and organizes details such as HTTP method, path, headers, status codes, and payloads.

* Easy Integration: Simple to integrate into existing Ruby projects, making it easier to debug and log HTTP interactions.


### Example

Given the raw debug output from Net::HTTP, the gem transforms it into a structured hash:

```ruby
{
  :request => {
    :method => "GET",
    :path => "/astros.json",
    :protocol => "HTTP/1.1",
    :headers => [
      "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Accept: */*",
      "User-Agent: Ruby",
      "Connection: close",
      "Host: api.open-notify.org"
    ],
    :payload => nil
  },
  :response => {
    :protocol => "HTTP/1.1",
    :status => "200",
    :message => "OK",
    :headers => [
      "Server: nginx/1.10.3",
      "Date: Thu, 13 Feb 2025 18:58:02 GMT",
      "Content-Type: application/json",
      "Content-Length: 587",
      "Connection: close",
      "access-control-allow-origin: *"
    ],
    :payload => {
      "people" => [
        { "craft" => "ISS", "name" => "Oleg Kononenko" },
        { "craft" => "ISS", "name" => "Nikolai Chub" },
        { "craft" => "ISS", "name" => "Tracy Caldwell Dyson" },
        { "craft" => "ISS", "name" => "Matthew Dominick" },
        { "craft" => "ISS", "name" => "Michael Barratt" },
        { "craft" => "ISS", "name" => "Jeanette Epps" },
        { "craft" => "ISS", "name" => "Alexander Grebenkin" },
        { "craft" => "ISS", "name" => "Butch Wilmore" },
        { "craft" => "ISS", "name" => "Sunita Williams" },
        { "craft" => "Tiangong", "name" => "Li Guangsu" },
        { "craft" => "Tiangong", "name" => "Li Cong" },
        { "craft" => "Tiangong", "name" => "Ye Guangfu" }
      ],
      "number" => 12,
      "message"=>"success"
    }
  }
}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_debug_output-parser'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
gem install http_debug_output-parser
```

## Usage

```ruby
require 'http_debug_output-parser'

debug_output = <<~DEBUG
opening connection to api.open-notify.org:80...
opened
<- "GET /astros.json HTTP/1.1\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: api.open-notify.org\r\n\r\n"
-> "HTTP/1.1 200 OK\r\n"
-> "Server: nginx/1.10.3\r\n"
-> "Date: Thu, 13 Feb 2025 18:58:02 GMT\r\n"
-> "Content-Type: application/json\r\n"
-> "Content-Length: 587\r\n"
-> "Connection: close\r\n"
-> "access-control-allow-origin: *\r\n"
-> "\r\n"
reading 587 bytes...
-> "{\"people\": [{\"craft\": \"ISS\", \"name\": \"Oleg Kononenko\"}, {\"craft\": \"ISS\", \"name\": \"Nikolai Chub\"}, {\"craft\": \"ISS\", \"name\": \"Tracy Caldwell Dyson\"}, {\"craft\": \"ISS\", \"name\": \"Matthew Dominick\"}, {\"craft\": \"ISS\", \"name\": \"Michael Barratt\"}, {\"craft\": \"ISS\", \"name\": \"Jeanette Epps\"}, {\"craft\": \"ISS\", \"name\": \"Alexander Grebenkin\"}, {\"craft\": \"ISS\", \"name\": \"Butch Wilmore\"}, {\"craft\": \"ISS\", \"name\": \"Sunita Williams\"}, {\"craft\": \"Tiangong\", \"name\": \"Li Guangsu\"}, {\"craft\": \"Tiangong\", \"name\": \"Li Cong\"}, {\"craft\": \"Tiangong\", \"name\": \"Ye Guangfu\"}], \"number\": 12, \"message\": \"success\"}"
read 587 bytes
Conn close
DEBUG

pp HttpDebugOutput::Parser.new(debug_output).call
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dbackowski/http_debug_output-parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
