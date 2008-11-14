require 'lib/stateology'

class Sample
    include Stateology
    
    state(:Happy) {
        def state_entry
            puts "entering Happy state"
        end
        
        def do_something
            puts "Pets a puppy"
        end
        
        def state_exit
            puts "exiting Happy state"
        end
    }
    
    state(:Angry) {
        def state_entry
            puts "entering Angry state"
        end
        
        def do_something
            puts "Kicks a puppy"
        end
        
        def state_exit
            puts "exiting Angry state"
        end
    }
    
    # methods declared outside a 'state' are part of the Default state
    
    def state_entry
        puts "entering Default state"
    end
    
    def do_something
        puts "stares at the ceiling"
    end
    
    def state_exit
        puts "exiting Default state"
    end
    
    # if we want the Default state_entry to run on instantiation
    # we must call it from the initialize method
    def initialize
        state_entry
    end
    
end

s = Sample.new

# in Default state
s.do_something  #=> "stares at the ceiling"

# now switch to Happy state
s.state :Happy
s.do_something  #=> "Pets a puppy"

# now switch to Angry state
s.state :Angry
s.do_something  #=> "Kicks a puppy"

# now switch back to Default state
s.state :Default
s.do_something  #=> "stares at the ceiling"

