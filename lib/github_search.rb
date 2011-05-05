require 'em-http-request'
require 'json'

class GithubSearch
  def initialize(term)
    @term = term
  end
  
  def first
    result['repositories'].first
  end
  
  def url
    "https://github.com/api/v2/json/repos/search/#{URI.encode(@term)}"
  end
  
  def result 
    fiber = Fiber.current
    
    http = EventMachine::HttpRequest.new(url).get
    http.callback { fiber.resume(http) }
    Fiber.yield
    
    JSON.parse(http.response)
  end
end