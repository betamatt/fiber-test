require 'rubygems'
require 'bundler'
Bundler.setup
$: << 'lib'

require 'eventmachine'
require 'fiber_pool'
require 'github_search'

pool = FiberPool.new(3)

# Read phrases from a file, printing the first github repo matching each
EM.run do
  File.open('phrases.txt') do |f|
    while (line = f.gets)
      line = line.strip
      pool.enqueue(line) do |line|
        repo = GithubSearch.new(line).first
        puts "#{line}: #{repo['name']}"
      end
    end
  end
  
  # Need a notification when all of the items on the queue are done processing
  Fiber.new do 
    pool.finish(Fiber.current) 
    Fiber.yield # wait for callback
    EM.stop
  end.resume
end
