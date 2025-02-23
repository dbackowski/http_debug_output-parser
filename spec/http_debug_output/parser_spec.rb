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

  let(:debug_output_for_post_request_with_long_payload) do
    <<~DEBUG
      opening connection to checkout-test.adyen.com:443...
      opened
      starting SSL for checkout-test.adyen.com:443...
      SSL established, protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384
      <- "POST /v70/payments HTTP/1.1\r\nContent-Type: application/json\r\nX-Api-Key: [FILTERED]Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: checkout-test.adyen.com\r\nContent-Length: 1294\r\n\r\n"
      <- "{"amount":{"value":0,"currency":"USD"},"billingAddress":{"city":"Golden","country":"US","houseNumberOrName":"","postalCode":"80401","stateOrProvince":"CA","street":"123 Main St"},"shopperEmail":"julian.mitchell272@example.com","shopperReference":"89bc3715-563d-40b1-bf3b-6999ac487d75","shopperName":{"firstName":"Jack","lastName":"Straw"},"shopperIP":"127.0.0.1","telephoneNumber":null,"paymentMethod":{"type":"scheme","number":"[FILTERED]","expiryMonth":3,"expiryYear":2030,"cvc":"[FILTERED]","holderName":"Jack Straw"},"reference":"c1173f61-99ad-4681-9e3a-249b98cfb1e5","shopperInteraction":"Ecommerce","recurringProcessingModel":"Subscription","storePaymentMethod":"true","merchantAccount":"MaxioCOM","store":"ST3224Z223223V5HZXB8T6BMW","browserInfo":{"screenWidth":1240,"screenHeight":1400,"colorDepth":24,"userAgent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/114.0.5735.133 Safari/537.36","timeZoneOffset":300,"language":"en-US","javaEnabled":false,"acceptHeader":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"},"authenticationData":{"threeDSRequestData":{"nativeThreeDS":"preferred"}},"channel":"web","origin":"https://sitex.test-chargifypay.com:53861"}"
      -> "HTTP/1.1 200 OK\r\n"
      -> "traceparent: 00-8c97462245018da73d3cac0b55dcc0a9-c74a2e3c8d8584db-01\r\n"
      -> "x-frame-options: SAMEORIGIN\r\n"
      -> "x-content-type-options: nosniff\r\n"
      -> "Cache-Control: no-cache, no-store, private, must-revalidate, max-age=0\r\n"
      -> "pragma: no-cache\r\n"
      -> "expires: 0\r\n"
      -> "Set-Cookie: JSESSIONID=DA9B9520341640B9C5647487F100B0C3; Path=/checkout; Secure; HttpOnly\r\n"
      -> "pspReference: DK9252VM5J88VVT5\r\n"
      -> "Content-Type: application/json;charset=UTF-8\r\n"
      -> "Transfer-Encoding: chunked\r\n"
      -> "Date: Sun, 23 Feb 2025 02:42:25 GMT\r\n"
      -> "strict-transport-security: max-age=31536000; includeSubDomains\r\n"
      -> "Connection: close\r\n"
      -> "\r\n"
      -> "4000\r\n"
      reading 16384 bytes...
      -> "{"resultCode":"IdentifyShopper","action":{"paymentData":"Ab02b4c0!BQABAgB0iOywXseI7JcO\\\\/H5B+yuQjqHKlHRY2gPXLK6QGjGSC1RuelwE\\\\/UBnqxhBeNLg8vWSZJKfI2JBhX7DnsRxAVevBuvuXXkx7E9ncZb+rULWh\\\\/RInFY9LoW1ZapTSojhpaGmMdItA18h7dKtZtujJ68\\\\/qgdNz0nRErG6tVfvwET+H6kpnTcpycBf0zK4pxqvlx6DdMIlkQ7p+KGXAsKIARBxBAH8C1xLh8EfVsVhmfmi1fPBLDWlqCSnkVXK8mw\\\\/H+rEae+w4dO8tKWPD5xuAIIQCzh3+Q81D697Q9VMRbTWg+gtMqIe1g2gxs3Akj7KbLiPDUpewoq31+sWZM5FupJvFhRxPwD0NEE8O3lDjQ9\\\\/TB6\\\\/Hnnqo1mEPhChwIGhK2SMiPWaKlq1BP0SC69BKAbUs8sGfI1X5pO+GZQTDHKPfXZ4N7iA8a\\\\/O9cUrKN1kKRyGpeHLH2JkBkUKhBWkqZBcXk2xKfttCNfUGWbSqkjl\\\\/unixHuN3Wf5SNWPyoLvaL4HbaW6KK9YxaVpuBOPsjwEmLnigkeWque2IcPu5tbLlzx3urkGnJXqZrrDJ0vinEEU35v1xfTMdYl+BSLXjbz2jCNoWqEtd6thKd\\\\/4sLA2QDVHEZZ6q6n3iYw34KgIARn5rkUHw6+vdioIsFLAWKjWdZxHSC52SZS+63Y37g\\\\/R8QxAUuuf9LiHDD0E\\\\/FkASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9fG3zLNB35HOwqKIEcM7zPH8q+JSYYZgDa0CGOmCDfAUdrUNB9t0q\\\\/UlJdtRDrpbVveZxPChd+\\\\/dXBWROzgA12uFTRQGzal8AB5vs45rqBWEUy+fWWf+2Sg9utxpRZ4e4nNI1FjHKiYYtfaSBvpfabf3nU7Ic5ADIW+ZkhtRsmAs1QRH1VLX0N+AfQnjCNxZk9ikK3G4O3H74K2nOD2SJxhp3W9MOITXeCdmoFf+PZ1U1bAD6u6+Rikn5dTM0wD2R3F\\\\/\\\\/Ng63kNIOgSa8PU8yYWw0P62wX6umXWBlmxgBOk3wz2kycsoTNNL\\\\/DnTt4xnRBhP8CVkNd5jm8IDyt1K+JMinb1B4TIyrDWzlEPj60cwsdg5Qaf9839MgrGJZxdCRZSvKkZ6tgc9Q7lVjK2rg6+9UVu6AUSHX5iqGCFgcH++eJS8pAH1WFklrPwFO2iD\\\\/uugVvYbpzoq6YmstvpMXH1w3SiUkkP6VhPNOhFLBa0nEuamGHyi1SJRMpubjcogHfBlezkiiiy2x1RkxR2Kr5l9Q5m78b\\\\/m0C583j+vdc8im\\\\/Zk083moWh5ayTcjkYTgMSDkbidLM2vMcYA1g8WltV8qyrvOMT3XZyJR\\\\/ZFuMYO8mCH3N0uwEslNKNC4PkI+6bN2+PQEtCafgxq93+DzGePVSLQXan8x261DHah7IdWGq+MZzXCe3pVcZ1uK\\\\/svrhTfiyzJWKGs8zRkaBdtInZhEEOvdg2byepirYcZXIz+Ph3VFr258A5rMJAtASooO53jw5ncs0bAldMgOM9ajqlcPfYOmrFkZomwVe06TPAFUylUn5goPylu3Hkdv7FFihwrdamPAWYFoI9zef2+yYpzP09qxjliMNQDB6YFdpKo2HuAgukryMU8XMP1rm3SBv6aKFtVoRTHrJi55roN0weOM7HzdqhERaMA+GVoqaNlj1qz8Jpj7b8eCCoVs5W99Cjm65KlHVxvPqc6\\\\/NxKS0SpW\\\\/lpNJqV87YNjmh2tRC2HDoUpZQaBrSjiOyrS\\\\/2RbyzBcPCfENyCYgTnxtZAmE6AhyaR85UdFH1a5zSCezpCoTLe4XPLK\\\\/Oic7GscNGN8sft5W9rp+U4uItyyfBIoA6l1yH2hoGpSsLgrssvYkDkwQOsFAnugbHDz1IO5aKEI5tpWPW9Di0IUJDGvVbYBqssgeSunhawfLk9iEVo67CVK9kHgq2GNr5mZibpaBNtzqdf839WbXFzVbPziTq+IhbFLrtabWoewiMVuRGED9Bl6ap76rx3dW7RCcQs\\\\/G1c1NXKM85CVvwll6f\\\\/Q7UgW1+ISsROzzBUR53JC5xabVxV30P5ny8j8tJo71NvhD4lQFUTYdergxDeODeiz2ieulDEwDOSLZH26qQ8DJ+Dk5tykFNXBJuNtjlLJvNgeSc\\\\/Reld9HxskiSAgXaSIueWEiNawLYIRCvcLyNM+l\\\\/Qnq00WmYG04C+xsuJ0ktOvwuXngwliMGUOxvw5TBwryOJFpfPXmTtjGmZl8P9Z0D\\\\/yXYoLeZUAVmNWs9CHQhjq\\\\/SOuZqwY0MRUti8a0Tzq6VN\\\\/GtvpLVTwCVfOpZB2Xu0Hr74GJsjrqT8V5cWQdnWtDc3KCQyjTBoTa3wOfgUmmuNh+e3IrhdAHdOh\\\\/hZikIZpWmzfrI7Sy0EUIwZYBxgiSbcTMteq09478BR+2cc0zpS5zQdrmyRVny2A8Hg4zxIrknUzmUB4E\\\\/LSOiE69O\\\\/qD5\\\\/E2U2zSKw1OHt4cB7UiKhLpdzqd65LviHC4nE+tV+MXoJF3yrAXEU0VF3RFDSxsxtp79inuPexj1e8QLYiaeh3NTR4vc36r84lnS+IAMQYFJGQoD5Ojs1+XFUjWB22uKPehb+3tutKwRIOAaf6my8gwj\\\\/0orEfPh297ysIJ5B27pdJqwUl5u385tvrfZKAvXw+4GOuijEz8TDKwGSAVhBaB2xvpwOOCva9Z7CWWBqoDAVso659XQGqwfdj1E2YQJHBiUALIHGp4jIvlPRZqmRlzJlxhb0ufi0oQCLXOevImvvS1WgqhJgqb2Oad8jfS0utFVUcFYBObID7inCJK6\\\\/gX61pylVbBMVQt3DYiegYGU5OqlNpBJ9M9wQD6t0FuqLqzGZPv4B47BqPmGm\\\\/gQD\\\\/Kjeu0KrrSow10VlwkDYi6EMQzokoS076Red9OSff+a93DOjo7dYJcZrHvmnBNxLSVb69vFZ+5UYexRiBGfyCc11dzBkLrPV8RzPO\\\\/0CztAUZiRCnU7ZfVd73emK6szUupT0dg7hstUX5Bi9Y8IgX576v6fj77Di1ady6A\\\\/4pnHYynQZ9c4n+1anelQ4PqTmaCWlCkBYfmlna3X43+LSSnuw0azTvSJjT+t5YHDQiC9L3heUGC2WZRhFP06yfIrctCyKcd\\\\/ClgEjtWNY0by29mC5bMUozHNvjNgpwIcE8x2\\\\/RUdlpbLK6dRVfK+5+PI9VZP4jYWv2XSjrWmKRcgqMYruuLI+iWT\\\\/hn8cTfLCKL6FE7EGx\\\\/d4L6yFo1yeM2GbHjXTLCfOMPnqKGHs\\\\/hdwduOEs++ULOVQCGXKnCBEga2EC6eIBBQlEFVYis+GymgAiQ7vuCvIpR6n1oNg\\\\/xYuQYjjnwzvdOqpCP6j+WMYElIpqTq7S2FkHkq06Egj75bgvKynrNUpc7EKb9WhxyImbAInQIhMsUEzgbgzOTShtAsuGXk3Hd4mhY4q7E6smm5tQ4g8\\\\/03XUmH+1IN5HuteQLkcv2b89AfdJxopzIR9bkFAn\\\\/wGIcleUwS54gZcB5KvYPE9VJhfLqj1MwnFH1khv5VY2BYV6w7qrG6uM4tRA1O9yWds3KeGUJyEa1nddJ4VSO9rHCZCMUVa9HDQsEevIkb9cy9OTzPg\\\\/9V7wGxykZM2A\\\\/BHadmKg+SRUsaQcjYFQD9f\\\\/I9siaGaQw3JmW7j7Y+3x2TcPH53N5b0bel0\\\\/Y2b7L5PdrGxKvcTEH75XHgSFa6a6LtpJQ1tUQIq00cnqLpcWL0ccjsKPEV9EnBILYZKufNfhw+ndONgmmZq3zmZ+AYW1rVmj\\\\/yzpM1NO4bA6VP\\\\/vEOqbMuc1PRobU\\\\/CHC4L\\\\/4m5n8B228iWyg3NXQ8TZSGfEVO048JGZzfsq96vDwxsbkcrkDoFNSrAkkzwmPQIRzNkWpT1Xlms57HAwE0hq69xQsXFvW53hgaPRcmrdIiL\\\\/L87izT\\\\/TwLMefugZV45G34kHF\\\\/2+tq55JXZ4adQQ+yx7\\\\/mcIl451Fafx5QgCrS4YCEpI4XXsDuuhA+Cr2+0V2c4FQmg0DJdNPuiuxwlcwHwI2IFesYJFxRUoy\\\\/W0QAf1Q1emY6K5gqzpKuXGMHMqRiuNGIpuJqDTxyCef6JpfGBjxeJT9SHrh+w\\\\/Mu96mX9m6DBEvRK8cvRLbOdJAb1clW4ZInxWKys\\\\/uZxtMPietr\\\\/SynKoZ8zUgOFbWc+vaUMSxrtW\\\\/RZRfIiU5JFahhiLIr2yUCCXGStzu58mOf7PzJpX+pbeS90+6Y\\\\/\\\\/5Od0iJpnW9hY+DKiYQ7gkyX7WsheRKb84Lxlcw9rcHnOd97D9Y4L6dKlLSCbEB1\\\\/VXi8jL2qtQtfj\\\\/GvbDlQhbC8t\\\\/G6eLPb\\\\/5acUxKW7aU1NEYcEprd+wjH8Sw6kYtBIQI53bcZbHTOTKbcqAYaDLH8RBIdbwSR9Jb+rjwZJTDTLWMTcyMhbxf8PC10HPHytUmlu0IjL7Na4lUBq3l3ntniu07clhv+tGd\\\\/AsszBWBlzDG2586xSeMb6qJVZTg8rhgdBehiv8rCbdOhdxfEeeTljI6RBkDvyKjzgVLPLbtj4IeOkPzrXq83dm0jzLCUwJbafhLYi58BmcroT92OR86t3FPgjQMmlcpsR9c37Kb0HYqcBQtQwReql\\\\/2Cb18RWfdFN5c0ULBIW0bR7m8IvdmAXnsWqO8ir1CnBkP+ma1WG5MmbEVVkMly8ZL18UPne580Ymrm9eTh+ggpyHKTn1rlHBk4\\\\/yg4qOFQ+G+5VMSjp3RNRPiRzAhnbheAE4y2plTrzy4gePudBZ8fxQEqOb5s6\\\\/3Zs02IEpKnbVXIXkeCDR3szIpFk\\\\/tz0Ku6aQWjBfHsY9tOzit1KFyomZlOFCk\\\\/zo8MW2OSyOq8QzeRlo1iWpvGmEbJmYxVr0n9CoK5q5K8hgDyUvAHQApv+iFiFwzoEAx6cCIJusjn9TxrjE5GXyGo3av+XKEIn+t1rHEwsBD8aPbg\\\\/X6JRRdVq57GwLDc1VxStq7tdVpXyuREKHBmtxBFp\\\\/njYa+aSCMU44FF6zt\\\\/eWtUfO1xBbsEu\\\\/Gs7z6LquP9YyQqAOuvASYvEErSJJSaU7qFBuDBvfbgjo\\\\/Jt7j4flZ5ID3Vt4Eqco0dxI9AGlFPZBIGJwbf+tfh+7ijNtMOdrEqnOrvD7Gwa2TbJKZ8qe1+fqd+mvpMy8PoHHhNy3BLjE1r5CEsH8KWEsh9eZNCiZEvocM+6jZ71SuFYn4AjDGfnqb4S+AFC3trRLyCULOpkl8dI7JBXDO+caMY+BSRoFqpOX1lLNywBfn\\\\/K1NuyE\\\\/feqN0T2slipMcKXDnYQxNvQQzrzL5b18H9oNHkEpjPUtaPuhvNwII\\\\/EntaVZGYjCzm4BON0aKjdKtyN5VeJiKQnMWxftRFh0LuK0+wH55AxG8Cw0teDSzsaORTa4xiTIZ+niskbPfhGbxOkvJkOTuzgVuLSNRL6QLEkzVQw1PmxRAcvmMvxPO+rkXZe36UO5GJkcxRMEiliTuLJUwXVsJ1z0Ftf5Z6t5fV3p+tfwP8hJRLPtk0wYCzEw4G27AgwgooqP1Rd7HMz+e292g+mQQkbz\\\\/uo24n5t\\\\/GrJro5oPm8luqiLDX52eRjiHCHWssQ04qQFfMPEbK6uo2dVba3gne6ESUKRjElHq07zLKnkLrWfZfsb0Y0cebihlkNMudxsiGUuQEq+itjrv45YIxEJAJL3CurAYXpfTCB4d6lpgoxIa8oSQVbKiFn5DLLSLAON2HgLBvx8E8qChsWqjAycafeNJI5Wk\\\\/N4eE4tgs7XedGv3Ikgzs7nZmeivnnIWEW\\\\/rXvBGSCVepS\\\\/JugtPBgbX3J5\\\\/Fggd6vk06Qg8NA6MpAyxM1XSCUAQFr0oQ4ewkxbwmPa6pjxfswvyL6bINNReda0IkSjVTSzPO895rp7EhiV2+Q88q0sqVb\\\\/b3aUKKcGJm\\\\/6I6\\\\/4R6A7OMtlm8Y9pMJ8\\\\/xCX552oIkOmcid1VTjdl2NtNDJzF0NmuZ6732wGpfP6ij2BjgzjLpBCVmEI0IcieOTXQN6oKjvpSGvnqY9TNnlECM5wpqfe8WbTko00YLwX9UyY1jDLmSTHRqWYmVMJudJIte5S2fqupwHhxka2YLdDu8dAyz5EEv3e\\\\/pgWQePMP5ajqdctB4DuhcBrIHJ7Wh4QQ9HI\\\\/x3Gn8+thLt4PZd6V\\\\/a026VAkalCpHg8GqO\\\\/yF2yyzm2QcLXvPZeDROsW58hWmc1XVlzuMBpFOQP4cw8xvToo2oTijyYyWDvWhXwsbVJ8vfldop4fTKrvbyBNET1JS2sWl64QETmRjHCJX\\\\/2SB0Mt\\\\/S87DFcZolQ8l2AxlPVgI6lmviLfLalisStpN47dPaSATvym3jd6OJdqD3WNXqDQbBAcWlgJFxxStm4X\\\\/u21hB075j5mNsQdjvKgAWpJA2q4U+fjw1dDGTo78U1DceKozQcWGDvoIUXaRwN3sJemKI4Iejy1ihURf\\\\/FzRcpsSzMqjSAyvNfNkclhu\\\\/FMFKaNLhPpb4DbEoOl5jN2eISsIxJKHe48Xo3tyHjdVDkoUX9DU0e8w7V47GpImIbNwYtaNUsq3SXxGCm+giRk+Win0YKPFUyelK1yRv8hknnu25s0PzsSPnqHy+pe8n4dfS3YJtZ9hEME3\\\\/B9qC6uMzq8uufm0fSj90B65s5yhyxpsVvAHUYhoimfS0\\\\/8mZLaHCZ0RVkJobBBOGi+05booKc5NaMseMy6nvZN0TugGSLVztmnQHjXCMExo5p25VsbTzyxqnnVKoeAV58+TUO65kQ1voHr\\\\/d0g\\\\/UeMf03RYX3H045rkbE\\\\/OY6tYLfHCHFyabCe4TcnU425HGf\\\\/u94\\\\/NnZpCVWTXhK9\\\\/ET7PWfaUIFwWDPnXD+Fk1IfRkbQlIwp3uMHTIjlioFfTsHdfEAhYcUZs5ZlHnAeug07WuxFFIDRVM36QrO7lb1wIm1yd67gCGfDY94ga52XiaCEk9LKGWVZRGEk7bomJWVV+BdTObAa66k3uEtCVBCYx1B\\\\/F6D0HBVlASv7YZAQFBIKKSu0ahuBONehx9VN4kwkQ7tebKzZMyRjss35VcHajnObFAbqnxwM0EUHeu0dTcQ8TAJte+h2J6AFUVg0ph3GBp6KW+n9l2ksW5lZXAV91EyaCrZURBLsQE7QJ9upddMfvVAAOFUFxvaGxfqfc0VM\\\\/P3M+6ywVe3YsZ7h6shQuk9JaG8xPVYZdo4PsflkecuL35FnLsjtNNgCsnulWZUszeu1UIiHkWDDREbTtA2rD6PXbmQlF2jFLVcaxSzFb72orCO7TXM6rVLfjdVfDEydAaravFh41IRG352nPxOt1yFsDANcPE0koV8Z+yQIzitsyq0H72dpqhgbT2NLPUiQSS2cZCVoeOf5Zrki8ru1t5I3d9pcD96dIcHd1SERDmrRvMJLojbKibQal0HRAYQ6n0pVZw1zyUHRZp2MKfOZl0F6ILenaFcDlEvZr7dpcqMmoZ5Jpl21Owg4cmzVBqKcMW6GyF8Ln+98b9HvJCL6bM5U24k6LBVatOBiQCGsQfQ6ZJVvAadL0RpXVIXq6toJkvZnBVu2tA8qOKdrVlTpn7te3T3rd1guGRhdvlE6dVA0Q\\\\/eHLEdBvbS\\\\/8vtg64mcFlNed63tgyX8QjgDbtlMKwStz2kSlm6fiBV9jBi71RN8lZfUEccS9qmrMPG1X8yZ77fNharhvMwmzQVBD0\\\\/5OrA\\\\/dMuC3AcWO8G+EPCiVuUR3pIcboF1X8EPqAD3CwJKilRJ9ykGKYyewstM0+u0KEi4c3z3bAshZTA95WeaQSXQfHJQxxJc\\\\/NSooyCn7\\\\/ch7RXo\\\\/PoCC1SlGR51E9ykWs1dRfpYGb0JmoOcJw7mHSi27yYOBz62TYLXtCFvNAKkkRYmDlcmoyfLjHMrwLVjpazG3pzldHxpkH32295qM5wdA7z1pYw5Lyr\\\\/S2RVuR2EvS3PGTKPsC\\\\/LtAWHPJZOufBdhm2mC8nzMTffWjFdI+\\\\/RbvHktjIz4Rz5+VQp\\\\/P1fY+H5TsL0+0kx20dWRxfOrkQNx2X8EklGtUqVZ4X8\\\\/gDWD62LkePaSxtRNJ4hSkBjw6\\\\/KEUhNrH5f\\\\/ZVfQPQW5UCti00ykwMPOym2tuTFrOBs5uuJzh0xkU2pUYe6YRHOepiwf\\\\/Wo21V4cJL9WxPOuig+SYtBE5hhZg\\\\/j8SVgLOOZeR7RPYe\\\\/LLmQqSwuZH\\\\/e5tj6Z22O4wvpyrELKsaXvDLw2mFr9Ah69HS2SOvYUieU9RA0kWng+6h3m44M6lY7IBv+BfVFbW5LSfegjsfrewacMMUK\\\\/dibMP16sDivYFDlytnBQct2hKRNUKXXF+8sfJWNIM37\\\\/vSh6k9fh1a1ySEs6XhzlWr1XuJn35HsxoamsUMYhkIW9h+bSwkuFvSbUx08Q7HEnFk96Ch35k0jUIshzNJfqFXVxlvoKmRsei73voY8M\\\\/cV4QiWvEC5w2LqNRKUYhGdVJVLgsfMCGscsEcxe43zx5Xl0K4+SfIH8+K44VDmaSqhwGOa+WmSubmYuksEi25ahgEmPPCPexI7ozr424oDoQCi5jxotb5WE8EY+G4RBUT3WVGSTUO1hHlJb143OaWbO0jR5AwghQKoWxj7eDzsDdj7iAusQa6zjfXCyON1kiEostbw1b\\\\/pjVp36a5aUTRJ\\\\/mcxVUFY0+moOQQ94VN79Sv\\\\/1MkFdwj8NADCVQlRRMp+4WQRjY1h87PtwejMd1tDN5JW4KaJQA4pohG0bjeYXqEXRjvyoUk91r51YGZHdeDtaMDgmiSNWluRicrFHQ4LMiZcXUAmfkkGPheizZUs3IqMI+X7s9eyQnWY6ntLnmYNV6K+X+Z3Qa1kHzyO\\\\/qmA9d6J4hVkX\\\\/XV+a3mQtTeWRpOz+UNvEQlnfVpJPiCpdVEJ1SeF\\\\/UtORVu9d8R5SyZQlQIFRsrg8nRIvY5fS1bbHBJnjYBoZClh+sAG1B9MSNfc8\\\\/XI0OMi0sL\\\\/DFGC0eTw8FaBefJgSb\\\\/6pp1Pf8Z3zZH3lJ+mh6gZCQHX9Nylz0UdD7gKn5gu4vN0prjJcdqCGONVnICoKpeDm9KOI3xlHUC9h1Whma8dtlZilD48iNeJZ3EDRr9cYsB4zXSdNBPuN32PW\\\\/KzwMegA2MEnGMUR+XfSN08x6t9x8oUMNqgc0cyJU3zEKBxOa\\\\/YjnPUEyzXAkZY+RaipQChRa5ac9VTDLCTMOUArYeAGN5lFxo\\\\/sljPGjthe1lg2m1+dJ0N5qt8GSZ9lT+mBrPCNbthjuSDmt5mKtzdmti30BfXAn6+iaSkc4gyPn\\\\/RlXus7TGe\\\\/4cPs7MC2SDrn\\\\/ceKlC+U9xmcBKA9QY4Sa3+Wst3IhS0jYdNdtY71IT0wyjpIjJNuJwGnLNQ8IkZtEJNN+bPPpVUydl3cBFBcDptpi6YI+e+b50WeHGCcNCegLHo6vJ4W9kRNAKvr00Lkbpf3sywVkxmScfUm89erdm9tFejMy16A1Q+b1L5e3SVMxyGBu2Qbb7MYYuOfzR4iOlrpSh4s5ySZdmTa00anjLQXuAEujMY1VIrVjVyAdc3HmbVidQvGdXfvj6WwPzMiGVJ7aUl3nAX2OOcTCAM7\\\\/yica7NYNWZUk26iciDaM1bEsPV0gvYXdk0flAsxAwD+8VsYdw0nn\\\\/TMkKXpS6iIR7HjDc0S5IhvqF3A+DMJ24zyITlVQNMqRZiOGcXTPaoY8LCP6feso5ql\\\\/+u7N026XRzkGYnmDlu9FUeXt0lG3WRGjKETkGFJoqOr6DDwnHPOYG1Qtl2O2vYQvr8zfB25FuABOnSv7wBF+bDNbQF1bPWdgwhcfXnKraX0FZG0VQhNUEOT7Wwh74y+s0ISrkOUdaJbf5tFjacKy4OdP25PFvqmiwdL3oFBWNVm35XlONkKOgOwvueH0edJniEV9nJwbB+JZxEXbe1XoIj0rKeOnq4UEC5pOBCEwrz9xXnBanM\\\\/Z0Y7100dMYJRrvci9yjeGfA7cU2Q4rmfytsgjqqnUcv5yyTW6bEQW1PuytVuFB126eZRqbd04uD79uEDBlxGSFPgE2Wi3cbAIX1HeGDrGW++EwVxHkdd5EisNv4\\\\/uVKVm\\\\/VY9dF9N\\\\/RZpf1zObLUCwBWnwK\\\\/Zxl+DOcTnLCERfkzd0kWOAEC0sbvOhQGDF7t7uEZlgVspz9ixxLeE3MvvZD\\\\/wFM+lkoidCUnDiEKYuEmQIVRQafdZ07SvW0BeFIJY6ZgvEznWw\\\\/\\\\/6OSSiIMdJuiO4g2sbyIP4SszL9nzJeE8cPMeTylv\\\\/roi3BWGdJwsLjSSrlolqn8Pu2cZLk\\\\/yc\\\\/v8mPQp\\\\/TL4lx+myzH277k+8y\\\\/EYSFuCRuulPJgTGpLSTyZ6VIPNdWfPkUrwjc0EOk8e9QotLZlUQPpFh5Yrhamm1x2K6YKAsll0wdnsPDMTGzM1GQBKTBMtmfzuXi3ZGm3LBd\\\\/Zox7dT3q01q8ZyRMik7sajoXSEwqbGvlpLSaYA2In2wif+2BggsoaEV7euN7SPwKpD7+JGPBji0BzkqECeBoIOauEhfdzDnFWm+pusG6a6gQ6fwew2IHi2eeRFqP9f2RI9i\\\\/xvoDNolbGK1quVWvG4bFN0WyfynqnQc78bbEIHWAYE+VmqtrOJh0FeC+moW\\\\/brIApnTEGQQBNfMXTNw8+WT1ZBjNa+OmslVIwwWf4W0yqW17SaJW7OfI17KwOWJKdcSqz6nUzXYQg1y1ToLgihKD\\\\/dJPswV1ceuMt68tE2OIHeLOx8CNQGEAuDP4VOtPnbuYXsSXwDEMBFfQnCW675n5qO+wiprbBvFPyOXTCk2CBGHK4KlBAOcBkslBKo3cB+w6TtCsUoe6w\\\\/uEzqDpkNrAvaTPbTcB53JgDoR2Pc4\\\\/mY2PLR5JxVEQNMADSyEUK\\\\/JQmzL81I7EQsR2FMcLH1qmKseMkla\\\\/BZge+5lzGwl5K\\\\/aMwgxA65tgDeRYljk6+31hV4ycw5dE5d4RnE8I1EiG9uOpJg4P9wmNYMT9MBCpht2FHBaEPLXO+q5QPoHpPorNRTp1x+KWeEe3GcE\\\\/TzbGTElH4FTdfAXMfH38MVFKyPlAKaGxh52lV2S+1g5J58amYMrGENBsuGkk3ZtfAEv\\\\/Zpy1hayk+LIlSwrYqikBMSBxFAoTJAQb6MEvgxLMG4qXLlS7yiDVmoSDxT7suv0Qpyh60r9GXybFowi\\\\/ikL7evS06QqH+h8172YHQ+vc2DuJS6YzGIzlczvdWqAq\\\\/fWACQFIFlRhW+QC9RpDNXqIaQ3QRMCBAoijxNEOZAgcjwE5KRJ897CQDgQq4WM8ypI7ESYb5sbPtYJobrzr0njXh59D0vgG5xEkpBrbAgE8S6R81lJQGZVEnU\\\\/XR5enPpyWTinwsFqLwYrDMHgWnuUkPypne9TjMYBi6WT4NSO8lEI506IS2qntO3HUQzY+rR6VZkBHPTGprO\\\\/sxhwD6mY0iai\\\\/dQzXN+vuIkVIFTQmA6NTGjLESxx4iC2fuzVv6VSxGZHR2euhRl8gDYnHQfPD8fKkFT1UGkySHRJardG6Tk7PieLPOvWmdouQYiPLi6kvw4VJU\\\\/DpV2RFw9VR99N6m098kUcOr2eBzPs4Y43skrU+802zJC6ORDZyevTD12ANBQ98q26N5zE5gsMwLIsKlGE7293OWBjDNHf32pCVLpXtpTyQqOOR1UrYq3FDGh9feNVi8w+fcRXpotdkuPmnigC6xRVm\\\\/o5y\\\\/3md2ejl40tiXifmPlnrICF1giLgnXTR6t5CrZOP2VOw3v4s61n93B6SqZSh5dz1nWTGsLRmjxK80Id+vNXxLheslLNRiUG4iVi8Z7asNpYSMqWxcTT7+tAcPNzF9t4stEdxH7MFSjOulhYxRw+RFc+kJDtW9mbC7ayYP4jIaDjRxWSvundisD42i1NJxT8+AY3QHPt+PfYuh6KsGLmU4G7pwXIltJLHEojerj69rbrx7IjA==","paymentMethodType":"scheme","authorisationToken":"Ab02b4c0!BQABAgASxAIOrEZKsSzKO2xBF3bOLEJJQzD4HHtKqAAhtE7apCOGW0T4j6DNNiPSDUI+n+rBaaPlDmpIBsG4r3QTs55ysfPFSV0TrTz49q+69GX6dhsEuNhoLvp6hS3zHFodHv2mdqZJexRzc25MnXfaYJtcpaqg+U4uuyjCOiRUPREUZC5Jpy7prAlzxjZUWnCoDaD1psNIuzImMAco\\\\/v3wJZy7whr1khNNKRc4ZU12AH7EtXNOj2+s7wrrPLJTIIZGkYjD0nk72u2GM0wNvblP0w+9VBqv49ceUbWNgLBN8sF5r1\\\\/fb6u+foQEKca16BRE4nDDHIKKmERIJmViqFh7FX+OF611pgzNxSNNLmqFFxzhRyAH32tz07rzJY3nQNb68BRZP8PgStTRa\\\\/LUZqZvhh2Yb7OuYd7gB\\\\/K6py7ziT8k1phbjSMVjaP\\\\/ch5OHTzgCmZRnrqHTAjbbD+5S6iuPcpFGM4Gbb6rg1FEeW2ylIyHQzpRPz+BlS2pNQvgyGB0fiNEU1oKOGf8ardGJLb78JMD9ZxD95BOGWqHK99Iuwup9WZzBk6dzjHq\\\\/YSVv2WApIkHZA8NPQbWH6sXGLHkTglQDSEvBDtNKMrtb2KJ3I1jlNnaHwOVEwkFfFgBRtsBoUei4mayjeyMszG3AB1IQiIA7cRPRiuVTntZK4PaIX7HkgwRgv4edjXnQCwFJYwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9sHvCsh0RrHniucA0ZeMv1apVlBkZbIiuG5OgjdIc6kWQZuBYzs\\\\/LdXeKxZTub2s1+NmOE4TsFkSuvIWklUCKJ7YmSdmTzaWPQG0HBpA5tGWaZCoqIdKYTPhCtINrRzyG9pOXZ9vZNMVvdjDgR5TcXRhABkOW\\\\/ST5g2v5jQc2UyB6x8tV3QLCVjDZJBaJakZjZc\\\\/k64d7CsqnMhOpuQuM7bkeJKNjfVyFqDa68vng4z9s8ZuGw+1cv0x2MKV0dWNEIV1UqXqdARX7GaWuDNYhlNSi7x3C5sHeF3BqY8AThHHL4APp7\\\\/1Pu6ENWsSjxqPA76ny++vGDvPwn2D4Bflb2hapNepxomz7tNWRNmPVkSJbS+FN8NbQz3WNb6uFNaDDdQqUFpJXFwthZXDApSTwXg4cvETR9wTjE9qMXbR2\\\\/QF5QhUKjKBHIaA5\\\\/pI9Ptuzz+IpBNY+bcW0QD6sKupuBQB6XgCx5okm0eXTrXvuFQ3Yazp4EjqhaYYlEXTdvvC84fs+\\\\/igQLrYZSu4vpiTohhNDfojWzry23i2I7ATwsOSzgnjNPN5+RAhqxkx4obTzyAEOTZiq5mdRyEWcB2wCNO0IiszWCE97nj7kkZWd5+PdM1Jf8ofJ9QIxr6cWHeQZIMsW1thDiw6nOwGzf+pOJGdJ7n1gS5V2HD2gxAw9V0sXi08ymRqOJdJ5Gii8vAEPLimkdD76k2mMuYxTeHelWb7Beg0tpAco8L45\\\\/c58Drk5t2\\\\/mJs\\\\/L+4eeLr08QZYU9dwbo1F3lQPKqISzGCb0iJ71Wn7i8zk4xyxINGzb4Xg9LyrsHZu6uDyRCnD1+rdz1LDPEj10\\\\/+PIQZri36fZY32Yxv7kCx2wOEsxtyonidWs0S5oqofEmCTT3uHAS0t8qTs7eH88KFvu+Eu34ukXjhhUiQmifgMu\\\\/GQLBPLJ7HFGYOCgc\\\\/+N\\\\/+SEx3TJoJ6FsbZRZAsaW5RA7AJmOfwd+mDYN2F9CWf870SvLCiiO4Kt9MHE9AZw75bMlqJtwcmRCa+d6mLQPnGq8NLJgDWl4VqZiCQoKiUJ3bx2AuVjth3a8halYQ6a1au2tOVixrS1Wex9pXOiTm5UseoE9pApPs597ksHfqZljyfpAt\\\\/AGgSdeSzmpI6Lir7IyrwYEIr5WS9Dg3jVYXsLy7gAniG6yOHG5oE3qb\\\\/v4F5N3XV9HMrkPTscW\\\\/RmlpYlwXMfUZjQlViJYJVQxxn2VFLRV\\\\/wzdqoor78324XUhUwc5wfgkdAoSOdWUBSxfdPVQuA9W1jNqTklRhREkzt0inlxDEW286S1G2d\\\\/U9vDY+dnpbR+6uqP92VVtsAL\\\\/6cTAK3eg+3aK52\\\\/67xsyAjnm+bDETIh73X+pj7M\\\\/pbwt1UkUzVoPSoWlCRDiCGo5WM56odoYijcbRx1C2MsObTaoc1GeLC06JETPg8tYV8qrJevjg3fMAzY7ohYfijxiYDj5dlRu09pcTOudZTyoWmReA4fYx2i\\\\/vnxGIfJwr7jN6pr3EO9lt5ID73rRP2Cvjg8FxzBS7ZkAiHKFJUdP4RzpaSOek\\\\/bLUkLz87z5heJ8IvwCjpJRLg8JBJJNsIoZZuNwyvkhFFzYLxsns7S1E9FHPRPEfUSRga5b8EtZP0YBxnExvpk+EVrjYX+mpZps1fxBSsydH9ZeDOap91Fwob8bq0aWi3can4iZu4Zc86uyjwVZmORC61oMWCve1mItcKRw068f+Mf1LISHNejTaE0d90hACtSZUuyskvxDStblKwM\\\\/UTgaGUgmiTTZfB+q6l2xPwP7+nQiNDAq5SKXmdBJcb6cC+kOuqb82\\\\/reVTfyRxHD+WsW7nY\\\\/FKO1NMpI0UDYCoogpD\\\\/0679HvN1AToqVRks0ikAUpQdmemqG02eQa0+PzDELpl1mqQkE6AnN\\\\/y7d4HBNpXvaoXzjqZQrZ6FdYL8pdPQXqwYnT7Ymew8h4UyLukmKTRyxKaQltQ240aJrtnK5sEFMyjYiVW90A4ENnWXJrAw5G9WsHwc7kV7CH\\\\/zQAVZufCMmxc17WGHgZRBZvmw52b2XowD0ZXLKPUeu5+8vr\\\\/sIQFjeiEzW+NXf06AEq0+ucYAINaixbVJRcjOiVxrrtJna0UL8wXBvpK89UlnxhqjjQMqKYhiYW\\\\/2iUblJ8uONA3ZX686zM8b8o94hSezDwQtoMztt2yvZKW5TkGzBIWn7yxLZRyQ3lYen8HTo5On2KfnN6ZwZgXI7Ll4whMX8q2B\\\\/VEHR8uhhGWz0pT1Omght4bQH+voYLyyjr5jE0Z116lb3FI2qpdc9YYf8gAEh0NkItDxaSTJTGPmcKji40puj1AO6wNvaNfrRZ7LOJdh\\\\/bm8b31EI47Obd0ilmwNAoKk4p4nfDB56D1eBvqxZZvhdAIzMCKYbN3VP0BlNGSmCGBtS1CVeq3MZPOudVjd+joC5Q45pvNC9wAhrh6zsSscUlbEAvBgjyiwZk21xnwRckHbVn5RBHXmlDV8A8geurf7X8JxHAaqj9cmlMqWHVvxdhW+Srg+j4Q3udeSHhqkHyaAUd7odeY9igYiIpGSRQrt08QUptm4IptnUW55TFh"
      -> "WAnnE3HtIjxjeFm9ouvhau9lJQssOiKhvKAfmZIX+XH\\\\/U9nM8CvDIzC7OGVgczYpddoYiO3XXI6Rvm0svrF1fD2saNkHHBGikglVv8ml6CVJw35M8Alx07eu7nJojUu7DL\\\\/J6ucqw7JtnN1ZbE5m6uF5nhsdH7GvsGThrqCKXYhJ0fLn1ckSU2uKwHARCZZoak6BmpTof60TXXJ59u1j5wLn00Ic7SvgnedkspSKU\\\\/NvjfTde46UZcA2ChKiXU8yQBINiDGRYrrLVAIjDisKRrC7AaT1\\\\/cgzbdmSoyzmBXDFwUAZkJFNvmIWk83aO2dNDSCPDNmYnAZjePnEapebHPUmTi1PBKEp76Tv\\\\/DXc3WaF+6E\\\\/929LNjY43wWKAeQtfYbIgs6EDjuFds7QJobdUDAN+0fhpLolciSJMuC+KS4DUxhw5imSobZFn3PaS\\\\/LsrZssfADU7jS4GMwSZ9iYfHkda1PzPZdf5NNApr9RPY+6lsE0baQ7WpsVoAkKYFkU7gAbOaFVXuzq1G7KKk5zeGrSMeArgat9q86H1lkpTYIUoYxy8PtoXdYnDwBUMZSowHYQqCmrvIJm3Ri8SIyKF3CqgLs1jEItKLHRqPMBIi7BkzCNUZxkNCGykpwN3QZbRz8QyPfjabnc0woqjKKmu1EpG7"\n\nread 16384 bytes\n\nreading 2 bytes...\n\n-> "\r\n"\n\nread 2 bytes\n\n-> "605\r\n"\n\nreading 1541 bytes...\n\n-> "E2twmppWj\\\\/jGpB08GbuaT52OiUGdYXbfObDmt7uLTKGSlsp2RHZdd\\\\/\\\\/yyrO1ZJ1xE6bXi\\\\/bgloq3kzSO9KzIQvr3l\\\\/kxxmb9cS93BXCrX3AhVqlfIk56W1reM8RSgaXEeYNuCki3q+fFBOYQsmUzw99TWOPk\\\\/+P333SnYeLmDN0gySxgUykIJAbdRdcyHO2uG8mu8aa13lXLNUkujJxncS3YmbqQ308VZao+SqcvTykJu9f3Rbj2p7H3dfUwiseYBPeejGLZQN2Z3yNKM98X0OYcSmear74YIj\\\\/FNjMXhvP92C57bgbFgoePszRN2mK1PIpD4bH+O6dO\\\\/VU3mMTDHlp2oLf4GZzNT4y6CazIctq5mh5bzrOkqWCXM1ocWnuao1Bf5KXbARH7oHBEnEf6Evdm3qGVoRdix3bqTvWTXvfykCayCcWqQ+b16qlLkDEg+BDiOEaD\\\\/6qaY+JmMoAYJLEfl+e3p5GOuC6KQQZn2Qz+5FVhdlZzXVz+L+MzUXb0ag1l84sFnTnmNAyxHxSsdk\\\\/QkLrTsWZ8ptp22eriagOkG+DObpNk0zPCn1fYMG+rvcwZI4SoV7UD27sE55alKdLgZAkIQNR028GkH5nfLSEncGQ+4pZjaxIr39+HVFKHlZ0RhXEZrwwzIX03GeWsNd4dDyKKyGujxxx0uOAwiIaf\\\\/Tt29jabq5wmZ4rz5S04Ja6s28kxQcythX397GAcQMUNOd6zvhz+99vWvhnEIA5AioTgvK2evv7M+hh3Dq42P0JimnDd8vWukH84vfGNJY8Pxobt5Lc6CuVVBh1pRT\\\\/D8ZsUGdA\\\\/Dlpn1eItqovN5WGyxXed8EGszfvyMxziXRl3CAMVpSgXg6J0+7h8Vk=","subtype":"fingerprint","token":"eyJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNNZXRob2ROb3RpZmljYXRpb25VUkwiOiJodHRwczpcL1wvY2hlY2tvdXRzaG9wcGVyLXRlc3QuYWR5ZW4uY29tXC9jaGVja291dHNob3BwZXJcL3RocmVlRFNNZXRob2ROb3RpZmljYXRpb24uc2h0bWw\\\\/b3JpZ2luS2V5PXB1Yi52Mi5OWFo4OEZaNjlIRDhLNzgyLmFIUjBjSE02THk5emFYUmxlQzUwWlhOMExXTm9ZWEpuYVdaNWNHRjVMbU52YlRvMU16ZzJNUS5nRzV1bmtuVVYteGdSejZQQUk5bWlxbUt6bHlCNWNhX3ptdVR3Ukl5dUtVIiwidGhyZWVEU01ldGhvZFVybCI6Imh0dHBzOlwvXC9wYWwtdGVzdC5hZHllbi5jb21cL3RocmVlZHMyc2ltdWxhdG9yXC9hY3NcL3N0YXJ0TWV0aG9kLnNodG1sIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiJmNDdlNzAzNy05MDY3LTRmOWItODllZi01OTU4OTlhNTk5NjgifQ==","type":"threeDS2"}}"
      read 1541 bytes
      reading 2 bytes...
      -> "\r\n"
      read 2 bytes
      -> "0\r\n"
      -> "\r\n"
      Conn close
    DEBUG
  end

  let(:expected_output_for_post_request_with_long_payload) do # rubocop:disable Metrics/BlockLength
    {
      request: {
        method: 'POST',
        path: '/v70/payments',
        protocol: 'HTTP/1.1',
        headers: ['Content-Type: application/json',
                  'X-Api-Key: [FILTERED]Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Accept: */*',
                  'User-Agent: Ruby',
                  'Connection: close',
                  'Host: checkout-test.adyen.com',
                  'Content-Length: 1294'],
        payload: {
          'amount' => { 'value' => 0, 'currency' => 'USD' },
          'billingAddress' => {
            'city' => 'Golden',
            'country' => 'US',
            'houseNumberOrName' => '',
            'postalCode' => '80401',
            'stateOrProvince' => 'CA',
            'street' => '123 Main St'
          },
          'shopperEmail' => 'julian.mitchell272@example.com',
          'shopperReference' => '89bc3715-563d-40b1-bf3b-6999ac487d75',
          'shopperName' => { 'firstName' => 'Jack', 'lastName' => 'Straw' },
          'shopperIP' => '127.0.0.1',
          'telephoneNumber' => nil,
          'paymentMethod' => {
            'type' => 'scheme',
            'number' => '[FILTERED]',
            'expiryMonth' => 3,
            'expiryYear' => 2030,
            'cvc' => '[FILTERED]',
            'holderName' => 'Jack Straw'
          },
          'reference' => 'c1173f61-99ad-4681-9e3a-249b98cfb1e5',
          'shopperInteraction' => 'Ecommerce',
          'recurringProcessingModel' => 'Subscription',
          'storePaymentMethod' => 'true',
          'merchantAccount' => 'MaxioCOM',
          'store' => 'ST3224Z223223V5HZXB8T6BMW',
          'browserInfo' => {
            'screenWidth' => 1240,
            'screenHeight' => 1400,
            'colorDepth' => 24,
            'userAgent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/114.0.5735.133 Safari/537.36',
            'timeZoneOffset' => 300,
            'language' => 'en-US',
            'javaEnabled' => false,
            'acceptHeader' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
          },
          'authenticationData' => { 'threeDSRequestData' => { 'nativeThreeDS' => 'preferred' } },
          'channel' => 'web',
          'origin' => 'https://sitex.test-chargifypay.com:53861'
        }
      },
      response: {
        protocol: 'HTTP/1.1',
        status: '200',
        message: 'OK',
        headers: ['traceparent: 00-8c97462245018da73d3cac0b55dcc0a9-c74a2e3c8d8584db-01',
                  'x-frame-options: SAMEORIGIN',
                  'x-content-type-options: nosniff',
                  'Cache-Control: no-cache, no-store, private, must-revalidate, max-age=0',
                  'pragma: no-cache',
                  'expires: 0',
                  'Set-Cookie: JSESSIONID=DA9B9520341640B9C5647487F100B0C3; Path=/checkout; Secure; HttpOnly',
                  'pspReference: DK9252VM5J88VVT5',
                  'Content-Type: application/json;charset=UTF-8',
                  'Transfer-Encoding: chunked',
                  'Date: Sun, 23 Feb 2025 02:42:25 GMT',
                  'strict-transport-security: max-age=31536000; includeSubDomains',
                  'Connection: close',
                  '4000'],
        payload: {
          'resultCode' => 'IdentifyShopper',
          'action' => {
            'paymentData' => 'Ab02b4c0!BQABAgB0iOywXseI7JcO\\/H5B+yuQjqHKlHRY2gPXLK6QGjGSC1RuelwE\\/UBnqxhBeNLg8vWSZJKfI2JBhX7DnsRxAVevBuvuXXkx7E9ncZb+rULWh\\/RInFY9LoW1ZapTSojhpaGmMdItA18h7dKtZtujJ68\\/qgdNz0nRErG6tVfvwET+H6kpnTcpycBf0zK4pxqvlx6DdMIlkQ7p+KGXAsKIARBxBAH8C1xLh8EfVsVhmfmi1fPBLDWlqCSnkVXK8mw\\/H+rEae+w4dO8tKWPD5xuAIIQCzh3+Q81D697Q9VMRbTWg+gtMqIe1g2gxs3Akj7KbLiPDUpewoq31+sWZM5FupJvFhRxPwD0NEE8O3lDjQ9\\/TB6\\/Hnnqo1mEPhChwIGhK2SMiPWaKlq1BP0SC69BKAbUs8sGfI1X5pO+GZQTDHKPfXZ4N7iA8a\\/O9cUrKN1kKRyGpeHLH2JkBkUKhBWkqZBcXk2xKfttCNfUGWbSqkjl\\/unixHuN3Wf5SNWPyoLvaL4HbaW6KK9YxaVpuBOPsjwEmLnigkeWque2IcPu5tbLlzx3urkGnJXqZrrDJ0vinEEU35v1xfTMdYl+BSLXjbz2jCNoWqEtd6thKd\\/4sLA2QDVHEZZ6q6n3iYw34KgIARn5rkUHw6+vdioIsFLAWKjWdZxHSC52SZS+63Y37g\\/R8QxAUuuf9LiHDD0E\\/FkASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9fG3zLNB35HOwqKIEcM7zPH8q+JSYYZgDa0CGOmCDfAUdrUNB9t0q\\/UlJdtRDrpbVveZxPChd+\\/dXBWROzgA12uFTRQGzal8AB5vs45rqBWEUy+fWWf+2Sg9utxpRZ4e4nNI1FjHKiYYtfaSBvpfabf3nU7Ic5ADIW+ZkhtRsmAs1QRH1VLX0N+AfQnjCNxZk9ikK3G4O3H74K2nOD2SJxhp3W9MOITXeCdmoFf+PZ1U1bAD6u6+Rikn5dTM0wD2R3F\\/\\/Ng63kNIOgSa8PU8yYWw0P62wX6umXWBlmxgBOk3wz2kycsoTNNL\\/DnTt4xnRBhP8CVkNd5jm8IDyt1K+JMinb1B4TIyrDWzlEPj60cwsdg5Qaf9839MgrGJZxdCRZSvKkZ6tgc9Q7lVjK2rg6+9UVu6AUSHX5iqGCFgcH++eJS8pAH1WFklrPwFO2iD\\/uugVvYbpzoq6YmstvpMXH1w3SiUkkP6VhPNOhFLBa0nEuamGHyi1SJRMpubjcogHfBlezkiiiy2x1RkxR2Kr5l9Q5m78b\\/m0C583j+vdc8im\\/Zk083moWh5ayTcjkYTgMSDkbidLM2vMcYA1g8WltV8qyrvOMT3XZyJR\\/ZFuMYO8mCH3N0uwEslNKNC4PkI+6bN2+PQEtCafgxq93+DzGePVSLQXan8x261DHah7IdWGq+MZzXCe3pVcZ1uK\\/svrhTfiyzJWKGs8zRkaBdtInZhEEOvdg2byepirYcZXIz+Ph3VFr258A5rMJAtASooO53jw5ncs0bAldMgOM9ajqlcPfYOmrFkZomwVe06TPAFUylUn5goPylu3Hkdv7FFihwrdamPAWYFoI9zef2+yYpzP09qxjliMNQDB6YFdpKo2HuAgukryMU8XMP1rm3SBv6aKFtVoRTHrJi55roN0weOM7HzdqhERaMA+GVoqaNlj1qz8Jpj7b8eCCoVs5W99Cjm65KlHVxvPqc6\\/NxKS0SpW\\/lpNJqV87YNjmh2tRC2HDoUpZQaBrSjiOyrS\\/2RbyzBcPCfENyCYgTnxtZAmE6AhyaR85UdFH1a5zSCezpCoTLe4XPLK\\/Oic7GscNGN8sft5W9rp+U4uItyyfBIoA6l1yH2hoGpSsLgrssvYkDkwQOsFAnugbHDz1IO5aKEI5tpWPW9Di0IUJDGvVbYBqssgeSunhawfLk9iEVo67CVK9kHgq2GNr5mZibpaBNtzqdf839WbXFzVbPziTq+IhbFLrtabWoewiMVuRGED9Bl6ap76rx3dW7RCcQs\\/G1c1NXKM85CVvwll6f\\/Q7UgW1+ISsROzzBUR53JC5xabVxV30P5ny8j8tJo71NvhD4lQFUTYdergxDeODeiz2ieulDEwDOSLZH26qQ8DJ+Dk5tykFNXBJuNtjlLJvNgeSc\\/Reld9HxskiSAgXaSIueWEiNawLYIRCvcLyNM+l\\/Qnq00WmYG04C+xsuJ0ktOvwuXngwliMGUOxvw5TBwryOJFpfPXmTtjGmZl8P9Z0D\\/yXYoLeZUAVmNWs9CHQhjq\\/SOuZqwY0MRUti8a0Tzq6VN\\/GtvpLVTwCVfOpZB2Xu0Hr74GJsjrqT8V5cWQdnWtDc3KCQyjTBoTa3wOfgUmmuNh+e3IrhdAHdOh\\/hZikIZpWmzfrI7Sy0EUIwZYBxgiSbcTMteq09478BR+2cc0zpS5zQdrmyRVny2A8Hg4zxIrknUzmUB4E\\/LSOiE69O\\/qD5\\/E2U2zSKw1OHt4cB7UiKhLpdzqd65LviHC4nE+tV+MXoJF3yrAXEU0VF3RFDSxsxtp79inuPexj1e8QLYiaeh3NTR4vc36r84lnS+IAMQYFJGQoD5Ojs1+XFUjWB22uKPehb+3tutKwRIOAaf6my8gwj\\/0orEfPh297ysIJ5B27pdJqwUl5u385tvrfZKAvXw+4GOuijEz8TDKwGSAVhBaB2xvpwOOCva9Z7CWWBqoDAVso659XQGqwfdj1E2YQJHBiUALIHGp4jIvlPRZqmRlzJlxhb0ufi0oQCLXOevImvvS1WgqhJgqb2Oad8jfS0utFVUcFYBObID7inCJK6\\/gX61pylVbBMVQt3DYiegYGU5OqlNpBJ9M9wQD6t0FuqLqzGZPv4B47BqPmGm\\/gQD\\/Kjeu0KrrSow10VlwkDYi6EMQzokoS076Red9OSff+a93DOjo7dYJcZrHvmnBNxLSVb69vFZ+5UYexRiBGfyCc11dzBkLrPV8RzPO\\/0CztAUZiRCnU7ZfVd73emK6szUupT0dg7hstUX5Bi9Y8IgX576v6fj77Di1ady6A\\/4pnHYynQZ9c4n+1anelQ4PqTmaCWlCkBYfmlna3X43+LSSnuw0azTvSJjT+t5YHDQiC9L3heUGC2WZRhFP06yfIrctCyKcd\\/ClgEjtWNY0by29mC5bMUozHNvjNgpwIcE8x2\\/RUdlpbLK6dRVfK+5+PI9VZP4jYWv2XSjrWmKRcgqMYruuLI+iWT\\/hn8cTfLCKL6FE7EGx\\/d4L6yFo1yeM2GbHjXTLCfOMPnqKGHs\\/hdwduOEs++ULOVQCGXKnCBEga2EC6eIBBQlEFVYis+GymgAiQ7vuCvIpR6n1oNg\\/xYuQYjjnwzvdOqpCP6j+WMYElIpqTq7S2FkHkq06Egj75bgvKynrNUpc7EKb9WhxyImbAInQIhMsUEzgbgzOTShtAsuGXk3Hd4mhY4q7E6smm5tQ4g8\\/03XUmH+1IN5HuteQLkcv2b89AfdJxopzIR9bkFAn\\/wGIcleUwS54gZcB5KvYPE9VJhfLqj1MwnFH1khv5VY2BYV6w7qrG6uM4tRA1O9yWds3KeGUJyEa1nddJ4VSO9rHCZCMUVa9HDQsEevIkb9cy9OTzPg\\/9V7wGxykZM2A\\/BHadmKg+SRUsaQcjYFQD9f\\/I9siaGaQw3JmW7j7Y+3x2TcPH53N5b0bel0\\/Y2b7L5PdrGxKvcTEH75XHgSFa6a6LtpJQ1tUQIq00cnqLpcWL0ccjsKPEV9EnBILYZKufNfhw+ndONgmmZq3zmZ+AYW1rVmj\\/yzpM1NO4bA6VP\\/vEOqbMuc1PRobU\\/CHC4L\\/4m5n8B228iWyg3NXQ8TZSGfEVO048JGZzfsq96vDwxsbkcrkDoFNSrAkkzwmPQIRzNkWpT1Xlms57HAwE0hq69xQsXFvW53hgaPRcmrdIiL\\/L87izT\\/TwLMefugZV45G34kHF\\/2+tq55JXZ4adQQ+yx7\\/mcIl451Fafx5QgCrS4YCEpI4XXsDuuhA+Cr2+0V2c4FQmg0DJdNPuiuxwlcwHwI2IFesYJFxRUoy\\/W0QAf1Q1emY6K5gqzpKuXGMHMqRiuNGIpuJqDTxyCef6JpfGBjxeJT9SHrh+w\\/Mu96mX9m6DBEvRK8cvRLbOdJAb1clW4ZInxWKys\\/uZxtMPietr\\/SynKoZ8zUgOFbWc+vaUMSxrtW\\/RZRfIiU5JFahhiLIr2yUCCXGStzu58mOf7PzJpX+pbeS90+6Y\\/\\/5Od0iJpnW9hY+DKiYQ7gkyX7WsheRKb84Lxlcw9rcHnOd97D9Y4L6dKlLSCbEB1\\/VXi8jL2qtQtfj\\/GvbDlQhbC8t\\/G6eLPb\\/5acUxKW7aU1NEYcEprd+wjH8Sw6kYtBIQI53bcZbHTOTKbcqAYaDLH8RBIdbwSR9Jb+rjwZJTDTLWMTcyMhbxf8PC10HPHytUmlu0IjL7Na4lUBq3l3ntniu07clhv+tGd\\/AsszBWBlzDG2586xSeMb6qJVZTg8rhgdBehiv8rCbdOhdxfEeeTljI6RBkDvyKjzgVLPLbtj4IeOkPzrXq83dm0jzLCUwJbafhLYi58BmcroT92OR86t3FPgjQMmlcpsR9c37Kb0HYqcBQtQwReql\\/2Cb18RWfdFN5c0ULBIW0bR7m8IvdmAXnsWqO8ir1CnBkP+ma1WG5MmbEVVkMly8ZL18UPne580Ymrm9eTh+ggpyHKTn1rlHBk4\\/yg4qOFQ+G+5VMSjp3RNRPiRzAhnbheAE4y2plTrzy4gePudBZ8fxQEqOb5s6\\/3Zs02IEpKnbVXIXkeCDR3szIpFk\\/tz0Ku6aQWjBfHsY9tOzit1KFyomZlOFCk\\/zo8MW2OSyOq8QzeRlo1iWpvGmEbJmYxVr0n9CoK5q5K8hgDyUvAHQApv+iFiFwzoEAx6cCIJusjn9TxrjE5GXyGo3av+XKEIn+t1rHEwsBD8aPbg\\/X6JRRdVq57GwLDc1VxStq7tdVpXyuREKHBmtxBFp\\/njYa+aSCMU44FF6zt\\/eWtUfO1xBbsEu\\/Gs7z6LquP9YyQqAOuvASYvEErSJJSaU7qFBuDBvfbgjo\\/Jt7j4flZ5ID3Vt4Eqco0dxI9AGlFPZBIGJwbf+tfh+7ijNtMOdrEqnOrvD7Gwa2TbJKZ8qe1+fqd+mvpMy8PoHHhNy3BLjE1r5CEsH8KWEsh9eZNCiZEvocM+6jZ71SuFYn4AjDGfnqb4S+AFC3trRLyCULOpkl8dI7JBXDO+caMY+BSRoFqpOX1lLNywBfn\\/K1NuyE\\/feqN0T2slipMcKXDnYQxNvQQzrzL5b18H9oNHkEpjPUtaPuhvNwII\\/EntaVZGYjCzm4BON0aKjdKtyN5VeJiKQnMWxftRFh0LuK0+wH55AxG8Cw0teDSzsaORTa4xiTIZ+niskbPfhGbxOkvJkOTuzgVuLSNRL6QLEkzVQw1PmxRAcvmMvxPO+rkXZe36UO5GJkcxRMEiliTuLJUwXVsJ1z0Ftf5Z6t5fV3p+tfwP8hJRLPtk0wYCzEw4G27AgwgooqP1Rd7HMz+e292g+mQQkbz\\/uo24n5t\\/GrJro5oPm8luqiLDX52eRjiHCHWssQ04qQFfMPEbK6uo2dVba3gne6ESUKRjElHq07zLKnkLrWfZfsb0Y0cebihlkNMudxsiGUuQEq+itjrv45YIxEJAJL3CurAYXpfTCB4d6lpgoxIa8oSQVbKiFn5DLLSLAON2HgLBvx8E8qChsWqjAycafeNJI5Wk\\/N4eE4tgs7XedGv3Ikgzs7nZmeivnnIWEW\\/rXvBGSCVepS\\/JugtPBgbX3J5\\/Fggd6vk06Qg8NA6MpAyxM1XSCUAQFr0oQ4ewkxbwmPa6pjxfswvyL6bINNReda0IkSjVTSzPO895rp7EhiV2+Q88q0sqVb\\/b3aUKKcGJm\\/6I6\\/4R6A7OMtlm8Y9pMJ8\\/xCX552oIkOmcid1VTjdl2NtNDJzF0NmuZ6732wGpfP6ij2BjgzjLpBCVmEI0IcieOTXQN6oKjvpSGvnqY9TNnlECM5wpqfe8WbTko00YLwX9UyY1jDLmSTHRqWYmVMJudJIte5S2fqupwHhxka2YLdDu8dAyz5EEv3e\\/pgWQePMP5ajqdctB4DuhcBrIHJ7Wh4QQ9HI\\/x3Gn8+thLt4PZd6V\\/a026VAkalCpHg8GqO\\/yF2yyzm2QcLXvPZeDROsW58hWmc1XVlzuMBpFOQP4cw8xvToo2oTijyYyWDvWhXwsbVJ8vfldop4fTKrvbyBNET1JS2sWl64QETmRjHCJX\\/2SB0Mt\\/S87DFcZolQ8l2AxlPVgI6lmviLfLalisStpN47dPaSATvym3jd6OJdqD3WNXqDQbBAcWlgJFxxStm4X\\/u21hB075j5mNsQdjvKgAWpJA2q4U+fjw1dDGTo78U1DceKozQcWGDvoIUXaRwN3sJemKI4Iejy1ihURf\\/FzRcpsSzMqjSAyvNfNkclhu\\/FMFKaNLhPpb4DbEoOl5jN2eISsIxJKHe48Xo3tyHjdVDkoUX9DU0e8w7V47GpImIbNwYtaNUsq3SXxGCm+giRk+Win0YKPFUyelK1yRv8hknnu25s0PzsSPnqHy+pe8n4dfS3YJtZ9hEME3\\/B9qC6uMzq8uufm0fSj90B65s5yhyxpsVvAHUYhoimfS0\\/8mZLaHCZ0RVkJobBBOGi+05booKc5NaMseMy6nvZN0TugGSLVztmnQHjXCMExo5p25VsbTzyxqnnVKoeAV58+TUO65kQ1voHr\\/d0g\\/UeMf03RYX3H045rkbE\\/OY6tYLfHCHFyabCe4TcnU425HGf\\/u94\\/NnZpCVWTXhK9\\/ET7PWfaUIFwWDPnXD+Fk1IfRkbQlIwp3uMHTIjlioFfTsHdfEAhYcUZs5ZlHnAeug07WuxFFIDRVM36QrO7lb1wIm1yd67gCGfDY94ga52XiaCEk9LKGWVZRGEk7bomJWVV+BdTObAa66k3uEtCVBCYx1B\\/F6D0HBVlASv7YZAQFBIKKSu0ahuBONehx9VN4kwkQ7tebKzZMyRjss35VcHajnObFAbqnxwM0EUHeu0dTcQ8TAJte+h2J6AFUVg0ph3GBp6KW+n9l2ksW5lZXAV91EyaCrZURBLsQE7QJ9upddMfvVAAOFUFxvaGxfqfc0VM\\/P3M+6ywVe3YsZ7h6shQuk9JaG8xPVYZdo4PsflkecuL35FnLsjtNNgCsnulWZUszeu1UIiHkWDDREbTtA2rD6PXbmQlF2jFLVcaxSzFb72orCO7TXM6rVLfjdVfDEydAaravFh41IRG352nPxOt1yFsDANcPE0koV8Z+yQIzitsyq0H72dpqhgbT2NLPUiQSS2cZCVoeOf5Zrki8ru1t5I3d9pcD96dIcHd1SERDmrRvMJLojbKibQal0HRAYQ6n0pVZw1zyUHRZp2MKfOZl0F6ILenaFcDlEvZr7dpcqMmoZ5Jpl21Owg4cmzVBqKcMW6GyF8Ln+98b9HvJCL6bM5U24k6LBVatOBiQCGsQfQ6ZJVvAadL0RpXVIXq6toJkvZnBVu2tA8qOKdrVlTpn7te3T3rd1guGRhdvlE6dVA0Q\\/eHLEdBvbS\\/8vtg64mcFlNed63tgyX8QjgDbtlMKwStz2kSlm6fiBV9jBi71RN8lZfUEccS9qmrMPG1X8yZ77fNharhvMwmzQVBD0\\/5OrA\\/dMuC3AcWO8G+EPCiVuUR3pIcboF1X8EPqAD3CwJKilRJ9ykGKYyewstM0+u0KEi4c3z3bAshZTA95WeaQSXQfHJQxxJc\\/NSooyCn7\\/ch7RXo\\/PoCC1SlGR51E9ykWs1dRfpYGb0JmoOcJw7mHSi27yYOBz62TYLXtCFvNAKkkRYmDlcmoyfLjHMrwLVjpazG3pzldHxpkH32295qM5wdA7z1pYw5Lyr\\/S2RVuR2EvS3PGTKPsC\\/LtAWHPJZOufBdhm2mC8nzMTffWjFdI+\\/RbvHktjIz4Rz5+VQp\\/P1fY+H5TsL0+0kx20dWRxfOrkQNx2X8EklGtUqVZ4X8\\/gDWD62LkePaSxtRNJ4hSkBjw6\\/KEUhNrH5f\\/ZVfQPQW5UCti00ykwMPOym2tuTFrOBs5uuJzh0xkU2pUYe6YRHOepiwf\\/Wo21V4cJL9WxPOuig+SYtBE5hhZg\\/j8SVgLOOZeR7RPYe\\/LLmQqSwuZH\\/e5tj6Z22O4wvpyrELKsaXvDLw2mFr9Ah69HS2SOvYUieU9RA0kWng+6h3m44M6lY7IBv+BfVFbW5LSfegjsfrewacMMUK\\/dibMP16sDivYFDlytnBQct2hKRNUKXXF+8sfJWNIM37\\/vSh6k9fh1a1ySEs6XhzlWr1XuJn35HsxoamsUMYhkIW9h+bSwkuFvSbUx08Q7HEnFk96Ch35k0jUIshzNJfqFXVxlvoKmRsei73voY8M\\/cV4QiWvEC5w2LqNRKUYhGdVJVLgsfMCGscsEcxe43zx5Xl0K4+SfIH8+K44VDmaSqhwGOa+WmSubmYuksEi25ahgEmPPCPexI7ozr424oDoQCi5jxotb5WE8EY+G4RBUT3WVGSTUO1hHlJb143OaWbO0jR5AwghQKoWxj7eDzsDdj7iAusQa6zjfXCyON1kiEostbw1b\\/pjVp36a5aUTRJ\\/mcxVUFY0+moOQQ94VN79Sv\\/1MkFdwj8NADCVQlRRMp+4WQRjY1h87PtwejMd1tDN5JW4KaJQA4pohG0bjeYXqEXRjvyoUk91r51YGZHdeDtaMDgmiSNWluRicrFHQ4LMiZcXUAmfkkGPheizZUs3IqMI+X7s9eyQnWY6ntLnmYNV6K+X+Z3Qa1kHzyO\\/qmA9d6J4hVkX\\/XV+a3mQtTeWRpOz+UNvEQlnfVpJPiCpdVEJ1SeF\\/UtORVu9d8R5SyZQlQIFRsrg8nRIvY5fS1bbHBJnjYBoZClh+sAG1B9MSNfc8\\/XI0OMi0sL\\/DFGC0eTw8FaBefJgSb\\/6pp1Pf8Z3zZH3lJ+mh6gZCQHX9Nylz0UdD7gKn5gu4vN0prjJcdqCGONVnICoKpeDm9KOI3xlHUC9h1Whma8dtlZilD48iNeJZ3EDRr9cYsB4zXSdNBPuN32PW\\/KzwMegA2MEnGMUR+XfSN08x6t9x8oUMNqgc0cyJU3zEKBxOa\\/YjnPUEyzXAkZY+RaipQChRa5ac9VTDLCTMOUArYeAGN5lFxo\\/sljPGjthe1lg2m1+dJ0N5qt8GSZ9lT+mBrPCNbthjuSDmt5mKtzdmti30BfXAn6+iaSkc4gyPn\\/RlXus7TGe\\/4cPs7MC2SDrn\\/ceKlC+U9xmcBKA9QY4Sa3+Wst3IhS0jYdNdtY71IT0wyjpIjJNuJwGnLNQ8IkZtEJNN+bPPpVUydl3cBFBcDptpi6YI+e+b50WeHGCcNCegLHo6vJ4W9kRNAKvr00Lkbpf3sywVkxmScfUm89erdm9tFejMy16A1Q+b1L5e3SVMxyGBu2Qbb7MYYuOfzR4iOlrpSh4s5ySZdmTa00anjLQXuAEujMY1VIrVjVyAdc3HmbVidQvGdXfvj6WwPzMiGVJ7aUl3nAX2OOcTCAM7\\/yica7NYNWZUk26iciDaM1bEsPV0gvYXdk0flAsxAwD+8VsYdw0nn\\/TMkKXpS6iIR7HjDc0S5IhvqF3A+DMJ24zyITlVQNMqRZiOGcXTPaoY8LCP6feso5ql\\/+u7N026XRzkGYnmDlu9FUeXt0lG3WRGjKETkGFJoqOr6DDwnHPOYG1Qtl2O2vYQvr8zfB25FuABOnSv7wBF+bDNbQF1bPWdgwhcfXnKraX0FZG0VQhNUEOT7Wwh74y+s0ISrkOUdaJbf5tFjacKy4OdP25PFvqmiwdL3oFBWNVm35XlONkKOgOwvueH0edJniEV9nJwbB+JZxEXbe1XoIj0rKeOnq4UEC5pOBCEwrz9xXnBanM\\/Z0Y7100dMYJRrvci9yjeGfA7cU2Q4rmfytsgjqqnUcv5yyTW6bEQW1PuytVuFB126eZRqbd04uD79uEDBlxGSFPgE2Wi3cbAIX1HeGDrGW++EwVxHkdd5EisNv4\\/uVKVm\\/VY9dF9N\\/RZpf1zObLUCwBWnwK\\/Zxl+DOcTnLCERfkzd0kWOAEC0sbvOhQGDF7t7uEZlgVspz9ixxLeE3MvvZD\\/wFM+lkoidCUnDiEKYuEmQIVRQafdZ07SvW0BeFIJY6ZgvEznWw\\/\\/6OSSiIMdJuiO4g2sbyIP4SszL9nzJeE8cPMeTylv\\/roi3BWGdJwsLjSSrlolqn8Pu2cZLk\\/yc\\/v8mPQp\\/TL4lx+myzH277k+8y\\/EYSFuCRuulPJgTGpLSTyZ6VIPNdWfPkUrwjc0EOk8e9QotLZlUQPpFh5Yrhamm1x2K6YKAsll0wdnsPDMTGzM1GQBKTBMtmfzuXi3ZGm3LBd\\/Zox7dT3q01q8ZyRMik7sajoXSEwqbGvlpLSaYA2In2wif+2BggsoaEV7euN7SPwKpD7+JGPBji0BzkqECeBoIOauEhfdzDnFWm+pusG6a6gQ6fwew2IHi2eeRFqP9f2RI9i\\/xvoDNolbGK1quVWvG4bFN0WyfynqnQc78bbEIHWAYE+VmqtrOJh0FeC+moW\\/brIApnTEGQQBNfMXTNw8+WT1ZBjNa+OmslVIwwWf4W0yqW17SaJW7OfI17KwOWJKdcSqz6nUzXYQg1y1ToLgihKD\\/dJPswV1ceuMt68tE2OIHeLOx8CNQGEAuDP4VOtPnbuYXsSXwDEMBFfQnCW675n5qO+wiprbBvFPyOXTCk2CBGHK4KlBAOcBkslBKo3cB+w6TtCsUoe6w\\/uEzqDpkNrAvaTPbTcB53JgDoR2Pc4\\/mY2PLR5JxVEQNMADSyEUK\\/JQmzL81I7EQsR2FMcLH1qmKseMkla\\/BZge+5lzGwl5K\\/aMwgxA65tgDeRYljk6+31hV4ycw5dE5d4RnE8I1EiG9uOpJg4P9wmNYMT9MBCpht2FHBaEPLXO+q5QPoHpPorNRTp1x+KWeEe3GcE\\/TzbGTElH4FTdfAXMfH38MVFKyPlAKaGxh52lV2S+1g5J58amYMrGENBsuGkk3ZtfAEv\\/Zpy1hayk+LIlSwrYqikBMSBxFAoTJAQb6MEvgxLMG4qXLlS7yiDVmoSDxT7suv0Qpyh60r9GXybFowi\\/ikL7evS06QqH+h8172YHQ+vc2DuJS6YzGIzlczvdWqAq\\/fWACQFIFlRhW+QC9RpDNXqIaQ3QRMCBAoijxNEOZAgcjwE5KRJ897CQDgQq4WM8ypI7ESYb5sbPtYJobrzr0njXh59D0vgG5xEkpBrbAgE8S6R81lJQGZVEnU\\/XR5enPpyWTinwsFqLwYrDMHgWnuUkPypne9TjMYBi6WT4NSO8lEI506IS2qntO3HUQzY+rR6VZkBHPTGprO\\/sxhwD6mY0iai\\/dQzXN+vuIkVIFTQmA6NTGjLESxx4iC2fuzVv6VSxGZHR2euhRl8gDYnHQfPD8fKkFT1UGkySHRJardG6Tk7PieLPOvWmdouQYiPLi6kvw4VJU\\/DpV2RFw9VR99N6m098kUcOr2eBzPs4Y43skrU+802zJC6ORDZyevTD12ANBQ98q26N5zE5gsMwLIsKlGE7293OWBjDNHf32pCVLpXtpTyQqOOR1UrYq3FDGh9feNVi8w+fcRXpotdkuPmnigC6xRVm\\/o5y\\/3md2ejl40tiXifmPlnrICF1giLgnXTR6t5CrZOP2VOw3v4s61n93B6SqZSh5dz1nWTGsLRmjxK80Id+vNXxLheslLNRiUG4iVi8Z7asNpYSMqWxcTT7+tAcPNzF9t4stEdxH7MFSjOulhYxRw+RFc+kJDtW9mbC7ayYP4jIaDjRxWSvundisD42i1NJxT8+AY3QHPt+PfYuh6KsGLmU4G7pwXIltJLHEojerj69rbrx7IjA==',
            'paymentMethodType' => 'scheme',
            'authorisationToken' => 'Ab02b4c0!BQABAgASxAIOrEZKsSzKO2xBF3bOLEJJQzD4HHtKqAAhtE7apCOGW0T4j6DNNiPSDUI+n+rBaaPlDmpIBsG4r3QTs55ysfPFSV0TrTz49q+69GX6dhsEuNhoLvp6hS3zHFodHv2mdqZJexRzc25MnXfaYJtcpaqg+U4uuyjCOiRUPREUZC5Jpy7prAlzxjZUWnCoDaD1psNIuzImMAco\\/v3wJZy7whr1khNNKRc4ZU12AH7EtXNOj2+s7wrrPLJTIIZGkYjD0nk72u2GM0wNvblP0w+9VBqv49ceUbWNgLBN8sF5r1\\/fb6u+foQEKca16BRE4nDDHIKKmERIJmViqFh7FX+OF611pgzNxSNNLmqFFxzhRyAH32tz07rzJY3nQNb68BRZP8PgStTRa\\/LUZqZvhh2Yb7OuYd7gB\\/K6py7ziT8k1phbjSMVjaP\\/ch5OHTzgCmZRnrqHTAjbbD+5S6iuPcpFGM4Gbb6rg1FEeW2ylIyHQzpRPz+BlS2pNQvgyGB0fiNEU1oKOGf8ardGJLb78JMD9ZxD95BOGWqHK99Iuwup9WZzBk6dzjHq\\/YSVv2WApIkHZA8NPQbWH6sXGLHkTglQDSEvBDtNKMrtb2KJ3I1jlNnaHwOVEwkFfFgBRtsBoUei4mayjeyMszG3AB1IQiIA7cRPRiuVTntZK4PaIX7HkgwRgv4edjXnQCwFJYwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9sHvCsh0RrHniucA0ZeMv1apVlBkZbIiuG5OgjdIc6kWQZuBYzs\\/LdXeKxZTub2s1+NmOE4TsFkSuvIWklUCKJ7YmSdmTzaWPQG0HBpA5tGWaZCoqIdKYTPhCtINrRzyG9pOXZ9vZNMVvdjDgR5TcXRhABkOW\\/ST5g2v5jQc2UyB6x8tV3QLCVjDZJBaJakZjZc\\/k64d7CsqnMhOpuQuM7bkeJKNjfVyFqDa68vng4z9s8ZuGw+1cv0x2MKV0dWNEIV1UqXqdARX7GaWuDNYhlNSi7x3C5sHeF3BqY8AThHHL4APp7\\/1Pu6ENWsSjxqPA76ny++vGDvPwn2D4Bflb2hapNepxomz7tNWRNmPVkSJbS+FN8NbQz3WNb6uFNaDDdQqUFpJXFwthZXDApSTwXg4cvETR9wTjE9qMXbR2\\/QF5QhUKjKBHIaA5\\/pI9Ptuzz+IpBNY+bcW0QD6sKupuBQB6XgCx5okm0eXTrXvuFQ3Yazp4EjqhaYYlEXTdvvC84fs+\\/igQLrYZSu4vpiTohhNDfojWzry23i2I7ATwsOSzgnjNPN5+RAhqxkx4obTzyAEOTZiq5mdRyEWcB2wCNO0IiszWCE97nj7kkZWd5+PdM1Jf8ofJ9QIxr6cWHeQZIMsW1thDiw6nOwGzf+pOJGdJ7n1gS5V2HD2gxAw9V0sXi08ymRqOJdJ5Gii8vAEPLimkdD76k2mMuYxTeHelWb7Beg0tpAco8L45\\/c58Drk5t2\\/mJs\\/L+4eeLr08QZYU9dwbo1F3lQPKqISzGCb0iJ71Wn7i8zk4xyxINGzb4Xg9LyrsHZu6uDyRCnD1+rdz1LDPEj10\\/+PIQZri36fZY32Yxv7kCx2wOEsxtyonidWs0S5oqofEmCTT3uHAS0t8qTs7eH88KFvu+Eu34ukXjhhUiQmifgMu\\/GQLBPLJ7HFGYOCgc\\/+N\\/+SEx3TJoJ6FsbZRZAsaW5RA7AJmOfwd+mDYN2F9CWf870SvLCiiO4Kt9MHE9AZw75bMlqJtwcmRCa+d6mLQPnGq8NLJgDWl4VqZiCQoKiUJ3bx2AuVjth3a8halYQ6a1au2tOVixrS1Wex9pXOiTm5UseoE9pApPs597ksHfqZljyfpAt\\/AGgSdeSzmpI6Lir7IyrwYEIr5WS9Dg3jVYXsLy7gAniG6yOHG5oE3qb\\/v4F5N3XV9HMrkPTscW\\/RmlpYlwXMfUZjQlViJYJVQxxn2VFLRV\\/wzdqoor78324XUhUwc5wfgkdAoSOdWUBSxfdPVQuA9W1jNqTklRhREkzt0inlxDEW286S1G2d\\/U9vDY+dnpbR+6uqP92VVtsAL\\/6cTAK3eg+3aK52\\/67xsyAjnm+bDETIh73X+pj7M\\/pbwt1UkUzVoPSoWlCRDiCGo5WM56odoYijcbRx1C2MsObTaoc1GeLC06JETPg8tYV8qrJevjg3fMAzY7ohYfijxiYDj5dlRu09pcTOudZTyoWmReA4fYx2i\\/vnxGIfJwr7jN6pr3EO9lt5ID73rRP2Cvjg8FxzBS7ZkAiHKFJUdP4RzpaSOek\\/bLUkLz87z5heJ8IvwCjpJRLg8JBJJNsIoZZuNwyvkhFFzYLxsns7S1E9FHPRPEfUSRga5b8EtZP0YBxnExvpk+EVrjYX+mpZps1fxBSsydH9ZeDOap91Fwob8bq0aWi3can4iZu4Zc86uyjwVZmORC61oMWCve1mItcKRw068f+Mf1LISHNejTaE0d90hACtSZUuyskvxDStblKwM\\/UTgaGUgmiTTZfB+q6l2xPwP7+nQiNDAq5SKXmdBJcb6cC+kOuqb82\\/reVTfyRxHD+WsW7nY\\/FKO1NMpI0UDYCoogpD\\/0679HvN1AToqVRks0ikAUpQdmemqG02eQa0+PzDELpl1mqQkE6AnN\\/y7d4HBNpXvaoXzjqZQrZ6FdYL8pdPQXqwYnT7Ymew8h4UyLukmKTRyxKaQltQ240aJrtnK5sEFMyjYiVW90A4ENnWXJrAw5G9WsHwc7kV7CH\\/zQAVZufCMmxc17WGHgZRBZvmw52b2XowD0ZXLKPUeu5+8vr\\/sIQFjeiEzW+NXf06AEq0+ucYAINaixbVJRcjOiVxrrtJna0UL8wXBvpK89UlnxhqjjQMqKYhiYW\\/2iUblJ8uONA3ZX686zM8b8o94hSezDwQtoMztt2yvZKW5TkGzBIWn7yxLZRyQ3lYen8HTo5On2KfnN6ZwZgXI7Ll4whMX8q2B\\/VEHR8uhhGWz0pT1Omght4bQH+voYLyyjr5jE0Z116lb3FI2qpdc9YYf8gAEh0NkItDxaSTJTGPmcKji40puj1AO6wNvaNfrRZ7LOJdh\\/bm8b31EI47Obd0ilmwNAoKk4p4nfDB56D1eBvqxZZvhdAIzMCKYbN3VP0BlNGSmCGBtS1CVeq3MZPOudVjd+joC5Q45pvNC9wAhrh6zsSscUlbEAvBgjyiwZk21xnwRckHbVn5RBHXmlDV8A8geurf7X8JxHAaqj9cmlMqWHVvxdhW+Srg+j4Q3udeSHhqkHyaAUd7odeY9igYiIpGSRQrt08QUptm4IptnUW55TFhWAnnE3HtIjxjeFm9ouvhau9lJQssOiKhvKAfmZIX+XH\\/U9nM8CvDIzC7OGVgczYpddoYiO3XXI6Rvm0svrF1fD2saNkHHBGikglVv8ml6CVJw35M8Alx07eu7nJojUu7DL\\/J6ucqw7JtnN1ZbE5m6uF5nhsdH7GvsGThrqCKXYhJ0fLn1ckSU2uKwHARCZZoak6BmpTof60TXXJ59u1j5wLn00Ic7SvgnedkspSKU\\/NvjfTde46UZcA2ChKiXU8yQBINiDGRYrrLVAIjDisKRrC7AaT1\\/cgzbdmSoyzmBXDFwUAZkJFNvmIWk83aO2dNDSCPDNmYnAZjePnEapebHPUmTi1PBKEp76Tv\\/DXc3WaF+6E\\/929LNjY43wWKAeQtfYbIgs6EDjuFds7QJobdUDAN+0fhpLolciSJMuC+KS4DUxhw5imSobZFn3PaS\\/LsrZssfADU7jS4GMwSZ9iYfHkda1PzPZdf5NNApr9RPY+6lsE0baQ7WpsVoAkKYFkU7gAbOaFVXuzq1G7KKk5zeGrSMeArgat9q86H1lkpTYIUoYxy8PtoXdYnDwBUMZSowHYQqCmrvIJm3Ri8SIyKF3CqgLs1jEItKLHRqPMBIi7BkzCNUZxkNCGykpwN3QZbRz8QyPfjabnc0woqjKKmu1EpG7read 16384 bytesreading 2 bytes...read 2 bytes605reading 1541 bytes...E2twmppWj\\/jGpB08GbuaT52OiUGdYXbfObDmt7uLTKGSlsp2RHZdd\\/\\/yyrO1ZJ1xE6bXi\\/bgloq3kzSO9KzIQvr3l\\/kxxmb9cS93BXCrX3AhVqlfIk56W1reM8RSgaXEeYNuCki3q+fFBOYQsmUzw99TWOPk\\/+P333SnYeLmDN0gySxgUykIJAbdRdcyHO2uG8mu8aa13lXLNUkujJxncS3YmbqQ308VZao+SqcvTykJu9f3Rbj2p7H3dfUwiseYBPeejGLZQN2Z3yNKM98X0OYcSmear74YIj\\/FNjMXhvP92C57bgbFgoePszRN2mK1PIpD4bH+O6dO\\/VU3mMTDHlp2oLf4GZzNT4y6CazIctq5mh5bzrOkqWCXM1ocWnuao1Bf5KXbARH7oHBEnEf6Evdm3qGVoRdix3bqTvWTXvfykCayCcWqQ+b16qlLkDEg+BDiOEaD\\/6qaY+JmMoAYJLEfl+e3p5GOuC6KQQZn2Qz+5FVhdlZzXVz+L+MzUXb0ag1l84sFnTnmNAyxHxSsdk\\/QkLrTsWZ8ptp22eriagOkG+DObpNk0zPCn1fYMG+rvcwZI4SoV7UD27sE55alKdLgZAkIQNR028GkH5nfLSEncGQ+4pZjaxIr39+HVFKHlZ0RhXEZrwwzIX03GeWsNd4dDyKKyGujxxx0uOAwiIaf\\/Tt29jabq5wmZ4rz5S04Ja6s28kxQcythX397GAcQMUNOd6zvhz+99vWvhnEIA5AioTgvK2evv7M+hh3Dq42P0JimnDd8vWukH84vfGNJY8Pxobt5Lc6CuVVBh1pRT\\/D8ZsUGdA\\/Dlpn1eItqovN5WGyxXed8EGszfvyMxziXRl3CAMVpSgXg6J0+7h8Vk=',
            'subtype' => 'fingerprint',
            'token' => 'eyJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNNZXRob2ROb3RpZmljYXRpb25VUkwiOiJodHRwczpcL1wvY2hlY2tvdXRzaG9wcGVyLXRlc3QuYWR5ZW4uY29tXC9jaGVja291dHNob3BwZXJcL3RocmVlRFNNZXRob2ROb3RpZmljYXRpb24uc2h0bWw\\/b3JpZ2luS2V5PXB1Yi52Mi5OWFo4OEZaNjlIRDhLNzgyLmFIUjBjSE02THk5emFYUmxlQzUwWlhOMExXTm9ZWEpuYVdaNWNHRjVMbU52YlRvMU16ZzJNUS5nRzV1bmtuVVYteGdSejZQQUk5bWlxbUt6bHlCNWNhX3ptdVR3Ukl5dUtVIiwidGhyZWVEU01ldGhvZFVybCI6Imh0dHBzOlwvXC9wYWwtdGVzdC5hZHllbi5jb21cL3RocmVlZHMyc2ltdWxhdG9yXC9hY3NcL3N0YXJ0TWV0aG9kLnNodG1sIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiJmNDdlNzAzNy05MDY3LTRmOWItODllZi01OTU4OTlhNTk5NjgifQ==',
            'type' => 'threeDS2'
          }
        }
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

  it 'parses debug output for POST request (201 response with long payload)' do
    expect(HttpDebugOutput::Parser.new(debug_output_for_post_request_with_long_payload).call).to eq(expected_output_for_post_request_with_long_payload)
  end

  it 'parses debug output for POST request (404 response)' do
    expect(HttpDebugOutput::Parser.new(debug_output_for_post_request_404).call).to eq(expected_output_for_post_request_404)
  end
end
