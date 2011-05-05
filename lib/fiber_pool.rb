require 'fiber'

class FiberPool
  def initialize(max)
    @max = max
    @fibers = []
    @queue = []
    
    max.times do 
      fiber = Fiber.new do |value, block|
        loop do
          block.call(value)
          
          if @queue.empty?
            @fibers << Fiber.current
            
            break if @done
            block = Fiber.yield
          else
            value, block = @queue.shift
          end          
        end
        
        teardown
      end
      
      @fibers << fiber
    end
  end

  def finish(parent)
    @done = true
    @parent = parent
  end
  
  def enqueue(value, &block)
    if @fibers.empty?
      @queue << [value, block]
    else
      fiber = @fibers.shift
      fiber.resume([value, block])
    end
  end
  
  private
  
    def teardown
      @parent.resume if @fibers.size == @max
    end
end