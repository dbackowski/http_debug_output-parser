# frozen_string_literal: true

RSpec.describe HttpDebugOutput::Parser do # rubocop:disable Metrics/BlockLength
  let(:debug_output_for_get_request) do
    <<~DEBUG
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
      -> "{"people": [{"craft": "ISS", "name": "Oleg Kononenko"}, {"craft": "ISS", "name": "Nikolai Chub"}, {"craft": "ISS", "name": "Tracy Caldwell Dyson"}, {"craft": "ISS", "name": "Matthew Dominick"}, {"craft": "ISS", "name": "Michael Barratt"}, {"craft": "ISS", "name": "Jeanette Epps"}, {"craft": "ISS", "name": "Alexander Grebenkin"}, {"craft": "ISS", "name": "Butch Wilmore"}, {"craft": "ISS", "name": "Sunita Williams"}, {"craft": "Tiangong", "name": "Li Guangsu"}, {"craft": "Tiangong", "name": "Li Cong"}, {"craft": "Tiangong", "name": "Ye Guangfu"}], "number": 12, "message": "success"}"
      read 587 bytes
      Conn close
      {"people"=>
        [{"craft"=>"ISS", "name"=>"Oleg Kononenko"},
         {"craft"=>"ISS", "name"=>"Nikolai Chub"},
         {"craft"=>"ISS", "name"=>"Tracy Caldwell Dyson"},
         {"craft"=>"ISS", "name"=>"Matthew Dominick"},
         {"craft"=>"ISS", "name"=>"Michael Barratt"},
         {"craft"=>"ISS", "name"=>"Jeanette Epps"},
         {"craft"=>"ISS", "name"=>"Alexander Grebenkin"},
         {"craft"=>"ISS", "name"=>"Butch Wilmore"},
         {"craft"=>"ISS", "name"=>"Sunita Williams"},
         {"craft"=>"Tiangong", "name"=>"Li Guangsu"},
         {"craft"=>"Tiangong", "name"=>"Li Cong"},
         {"craft"=>"Tiangong", "name"=>"Ye Guangfu"}],
       "number"=>12,
       "message"=>"success"}
    DEBUG
  end

  let(:expected_output_for_get_request) do # rubocop:disable Metrics/BlockLength
    {
      request: {
        method: 'GET',
        path: '/astros.json',
        protocol: 'HTTP/1.1',
        headers: ['Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Accept: */*',
                  'User-Agent: Ruby', 'Connection: close', 'Host: api.open-notify.org'],
        payload: nil
      },
      response: {
        protocol: 'HTTP/1.1',
        status: '200',
        message: 'OK',
        headers: ['Server: nginx/1.10.3',
                  'Date: Thu, 13 Feb 2025 18:58:02 GMT',
                  'Content-Type: application/json',
                  'Content-Length: 587',
                  'Connection: close',
                  'access-control-allow-origin: *'],
        payload: {
          'people' => [
            { 'craft' => 'ISS', 'name' => 'Oleg Kononenko' },
            { 'craft' => 'ISS', 'name' => 'Nikolai Chub' },
            { 'craft' => 'ISS', 'name' => 'Tracy Caldwell Dyson' },
            { 'craft' => 'ISS', 'name' => 'Matthew Dominick' },
            { 'craft' => 'ISS', 'name' => 'Michael Barratt' },
            { 'craft' => 'ISS', 'name' => 'Jeanette Epps' },
            { 'craft' => 'ISS', 'name' => 'Alexander Grebenkin' },
            { 'craft' => 'ISS', 'name' => 'Butch Wilmore' },
            { 'craft' => 'ISS', 'name' => 'Sunita Williams' },
            { 'craft' => 'Tiangong', 'name' => 'Li Guangsu' },
            { 'craft' => 'Tiangong', 'name' => 'Li Cong' },
            { 'craft' => 'Tiangong', 'name' => 'Ye Guangfu' }
          ],
          'number' => 12,
          'message' => 'success'
        }
      }
    }
  end

  let(:debug_output_for_post_request) do
    <<~DEBUG
      opening connection to jsonplaceholder.typicode.com:443...
      opened
      starting SSL for jsonplaceholder.typicode.com:443...
      SSL established, protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384
      <- "POST /posts HTTP/1.1\r\nContent-Type: application/json\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: jsonplaceholder.typicode.com\r\nContent-Length: 39\r\n\r\n"
      <- "{"title":"foo","body":"bar","userId":1}"
      -> "HTTP/1.1 201 Created\r\n"
      -> "Date: Fri, 14 Feb 2025 17:15:30 GMT\r\n"
      -> "Content-Type: application/json; charset=utf-8\r\n"
      -> "Content-Length: 65\r\n"
      -> "Connection: close\r\n"
      -> "Report-To: {"group":"heroku-nel","max_age":3600,"endpoints":[{"url":"https://nel.heroku.com/reports?ts=1739553330&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=Ec3KKEOMEMmt1G19Qu5Jgre8pqOxKOyal4FPo1Rg3Dc%3D"}]}\r\n"
      -> "Reporting-Endpoints: heroku-nel=https://nel.heroku.com/reports?ts=1739553330&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=Ec3KKEOMEMmt1G19Qu5Jgre8pqOxKOyal4FPo1Rg3Dc%3D\r\n"
      -> "Nel: {"report_to":"heroku-nel","max_age":3600,"success_fraction":0.005,"failure_fraction":0.05,"response_headers":["Via"]}\r\n"
      -> "X-Powered-By: Express\r\n"
      -> "X-Ratelimit-Limit: 1000\r\n"
      -> "X-Ratelimit-Remaining: 999\r\n"
      -> "X-Ratelimit-Reset: 1739553359\r\n"
      -> "Vary: Origin, X-HTTP-Method-Override, Accept-Encoding\r\n"
      -> "Access-Control-Allow-Credentials: true\r\n"
      -> "Cache-Control: no-cache\r\n"
      -> "Pragma: no-cache\r\n"
      -> "Expires: -1\r\n"
      -> "Access-Control-Expose-Headers: Location\r\n"
      -> "Location: https://jsonplaceholder.typicode.com/posts/101\r\n"
      -> "X-Content-Type-Options: nosniff\r\n"
      -> "Etag: W/"41-GDNaWfnVU6RZhpLbye0veBaqcHA"\r\n"
      -> "Via: 1.1 vegur\r\n"
      -> "cf-cache-status: DYNAMIC\r\n"
      -> "Server: cloudflare\r\n"
      -> "CF-RAY: 911eb357abdeb194-WAW\r\n"
      -> "alt-svc: h3=":443"; ma=86400\r\n"
      -> "server-timing: cfL4;desc="?proto=TCP&rtt=10301&min_rtt=10107&rtt_var=4178&sent=4&recv=7&lost=0&retrans=0&sent_bytes=2793&recv_bytes=894&delivery_rate=248349&cwnd=224&unsent_bytes=0&cid=71366974618887a2&ts=419&x=0"\r\n"
      -> "\r\n"
      reading 65 bytes...
      -> "{\n  "title": "foo",\n  "body": "bar",\n  "userId": 1,\n  "id": 101\n}"
      read 65 bytes
      Conn close
      Response code: 201
      Response body: {
        "title": "foo",
        "body": "bar",
        "userId": 1,
        "id": 101
      }
    DEBUG
  end

  let(:expected_output_for_post_request) do # rubocop:disable Metrics/BlockLength
    {
      request: {
        method: 'POST',
        path: '/posts',
        protocol: 'HTTP/1.1',
        headers: ['Content-Type: application/json',
                  'Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Accept: */*',
                  'User-Agent: Ruby',
                  'Connection: close',
                  'Host: jsonplaceholder.typicode.com',
                  'Content-Length: 39'],
        payload: {
          'title' => 'foo',
          'body' => 'bar',
          'userId' => 1
        }
      },
      response: {
        protocol: 'HTTP/1.1',
        status: '201',
        message: 'Created',
        headers: ['Date: Fri, 14 Feb 2025 17:15:30 GMT',
                  'Content-Type: application/json; charset=utf-8',
                  'Content-Length: 65',
                  'Connection: close',
                  'Report-To: {"group":"heroku-nel","max_age":3600,"endpoints":[{"url":"https://nel.heroku.com/reports?ts=1739553330&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=Ec3KKEOMEMmt1G19Qu5Jgre8pqOxKOyal4FPo1Rg3Dc%3D"}]}',
                  'Reporting-Endpoints: heroku-nel=https://nel.heroku.com/reports?ts=1739553330&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=Ec3KKEOMEMmt1G19Qu5Jgre8pqOxKOyal4FPo1Rg3Dc%3D',
                  'Nel: {"report_to":"heroku-nel","max_age":3600,"success_fraction":0.005,"failure_fraction":0.05,"response_headers":["Via"]}',
                  'X-Powered-By: Express',
                  'X-Ratelimit-Limit: 1000',
                  'X-Ratelimit-Remaining: 999',
                  'X-Ratelimit-Reset: 1739553359',
                  'Vary: Origin, X-HTTP-Method-Override, Accept-Encoding',
                  'Access-Control-Allow-Credentials: true',
                  'Cache-Control: no-cache',
                  'Pragma: no-cache',
                  'Expires: -1',
                  'Access-Control-Expose-Headers: Location',
                  'Location: https://jsonplaceholder.typicode.com/posts/101',
                  'X-Content-Type-Options: nosniff',
                  'Etag: W/"41-GDNaWfnVU6RZhpLbye0veBaqcHA',
                  'Via: 1.1 vegur',
                  'cf-cache-status: DYNAMIC',
                  'Server: cloudflare',
                  'CF-RAY: 911eb357abdeb194-WAW',
                  'alt-svc: h3=":443"; ma=86400',
                  'server-timing: cfL4;desc="?proto=TCP&rtt=10301&min_rtt=10107&rtt_var=4178&sent=4&recv=7&lost=0&retrans=0&sent_bytes=2793&recv_bytes=894&delivery_rate=248349&cwnd=224&unsent_bytes=0&cid=71366974618887a2&ts=419&x=0'],
        payload: {
          'title' => 'foo',
          'body' => 'bar',
          'userId' => 1,
          'id' => 101
        }
      }
    }
  end

  let(:debug_output_for_post_request_404) do # rubocop:disable Naming/VariableNumber
    <<~DEBUG
      opening connection to jsonplaceholder.typicode.com:443...
      opened
      starting SSL for jsonplaceholder.typicode.com:443...
      SSL established, protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384
      <- "POST /posts2 HTTP/1.1\r\nContent-Type: application/json\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: jsonplaceholder.typicode.com\r\nContent-Length: 39\r\n\r\n"
      <- "{"title":"foo","body":"bar","userId":1}"
      -> "HTTP/1.1 404 Not Found\r\n"
      -> "Date: Fri, 14 Feb 2025 17:51:21 GMT\r\n"
      -> "Content-Type: application/json; charset=utf-8\r\n"
      -> "Content-Length: 2\r\n"
      -> "Connection: close\r\n"
      -> "Report-To: {"group":"heroku-nel","max_age":3600,"endpoints":[{"url":"https://nel.heroku.com/reports?ts=1739555481&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=lhCsVlX60W0Zz%2BwdMvTPHZ%2BdQ0TtMbZmfArxFAZgAYk%3D"}]}\r\n"
      -> "Reporting-Endpoints: heroku-nel=https://nel.heroku.com/reports?ts=1739555481&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=lhCsVlX60W0Zz%2BwdMvTPHZ%2BdQ0TtMbZmfArxFAZgAYk%3D\r\n"
      -> "Nel: {"report_to":"heroku-nel","max_age":3600,"success_fraction":0.005,"failure_fraction":0.05,"response_headers":["Via"]}\r\n"
      -> "X-Powered-By: Express\r\n"
      -> "X-Ratelimit-Limit: 1000\r\n"
      -> "X-Ratelimit-Remaining: 999\r\n"
      -> "X-Ratelimit-Reset: 1739555519\r\n"
      -> "Vary: Origin, X-HTTP-Method-Override, Accept-Encoding\r\n"
      -> "Access-Control-Allow-Credentials: true\r\n"
      -> "Cache-Control: no-cache\r\n"
      -> "Pragma: no-cache\r\n"
      -> "Expires: -1\r\n"
      -> "X-Content-Type-Options: nosniff\r\n"
      -> "Etag: W/"2-vyGp6PvFo4RvsFtPoIWeCReyIC8"\r\n"
      -> "Via: 1.1 vegur\r\n"
      -> "cf-cache-status: DYNAMIC\r\n"
      -> "Server: cloudflare\r\n"
      -> "CF-RAY: 911ee7dd5aafb236-WAW\r\n"
      -> "alt-svc: h3=":443"; ma=86400\r\n"
      -> "server-timing: cfL4;desc="?proto=TCP&rtt=13949&min_rtt=11268&rtt_var=6141&sent=5&recv=7&lost=0&retrans=0&sent_bytes=2794&recv_bytes=895&delivery_rate=257011&cwnd=242&unsent_bytes=0&cid=72ecabc4e06ea006&ts=161&x=0"\r\n"
      -> "\r\n"
      reading 2 bytes...
      -> "{}"
      read 2 bytes
      Conn close
      Response code: 404
      Response body: {}
    DEBUG
  end

  let(:expected_output_for_post_request_404) do # rubocop:disable Metrics/BlockLength,Naming/VariableNumber
    {
      request: {
        method: 'POST',
        path: '/posts2',
        protocol: 'HTTP/1.1',
        headers: ['Content-Type: application/json',
                  'Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Accept: */*',
                  'User-Agent: Ruby',
                  'Connection: close',
                  'Host: jsonplaceholder.typicode.com',
                  'Content-Length: 39'],
        payload: { 'title' => 'foo', 'body' => 'bar', 'userId' => 1 }
      },
      response: {
        protocol: 'HTTP/1.1',
        status: '404',
        message: 'Not Found',
        headers: ['Date: Fri, 14 Feb 2025 17:51:21 GMT',
                  'Content-Type: application/json; charset=utf-8',
                  'Content-Length: 2',
                  'Connection: close',
                  'Report-To: {"group":"heroku-nel","max_age":3600,"endpoints":[{"url":"https://nel.heroku.com/reports?ts=1739555481&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=lhCsVlX60W0Zz%2BwdMvTPHZ%2BdQ0TtMbZmfArxFAZgAYk%3D"}]}',
                  'Reporting-Endpoints: heroku-nel=https://nel.heroku.com/reports?ts=1739555481&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=lhCsVlX60W0Zz%2BwdMvTPHZ%2BdQ0TtMbZmfArxFAZgAYk%3D',
                  'Nel: {"report_to":"heroku-nel","max_age":3600,"success_fraction":0.005,"failure_fraction":0.05,"response_headers":["Via"]}',
                  'X-Powered-By: Express',
                  'X-Ratelimit-Limit: 1000',
                  'X-Ratelimit-Remaining: 999',
                  'X-Ratelimit-Reset: 1739555519',
                  'Vary: Origin, X-HTTP-Method-Override, Accept-Encoding',
                  'Access-Control-Allow-Credentials: true',
                  'Cache-Control: no-cache',
                  'Pragma: no-cache',
                  'Expires: -1',
                  'X-Content-Type-Options: nosniff',
                  'Etag: W/"2-vyGp6PvFo4RvsFtPoIWeCReyIC8',
                  'Via: 1.1 vegur',
                  'cf-cache-status: DYNAMIC',
                  'Server: cloudflare',
                  'CF-RAY: 911ee7dd5aafb236-WAW',
                  'alt-svc: h3=":443"; ma=86400',
                  'server-timing: cfL4;desc="?proto=TCP&rtt=13949&min_rtt=11268&rtt_var=6141&sent=5&recv=7&lost=0&retrans=0&sent_bytes=2794&recv_bytes=895&delivery_rate=257011&cwnd=242&unsent_bytes=0&cid=72ecabc4e06ea006&ts=161&x=0'],
        payload: {}
      }
    }
  end

  it 'has a version number' do
    expect(HttpDebugOutput::Parser::VERSION).not_to be nil
  end

  it 'parses debug output for GET request (200 response)' do
    expect(HttpDebugOutput::Parser.new(debug_output_for_get_request).call).to eq(expected_output_for_get_request)
  end

  it 'parses debug output for POST request (201 response)' do
    expect(HttpDebugOutput::Parser.new(debug_output_for_post_request).call).to eq(expected_output_for_post_request)
  end

  it 'parses debug output for POST request (404 response)' do
    expect(HttpDebugOutput::Parser.new(debug_output_for_post_request_404).call).to eq(expected_output_for_post_request_404)
  end
end
