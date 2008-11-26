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

class SampleChild < Sample
    state(:Happy) {
        def do_something
            puts "pets a Kitten"
        end
    }
end

s = Sample.new
sc = SampleChild.new

puts "Testing Sample"

# in Default state
s.do_something  #=> "stares at the ceiling"

# now switch to Happy state
s.state :Happy
s.do_something  #=> "Pets a puppy"

# now switch to Angry state
s.state Sample::Angry
s.do_something  #=> "Kicks a puppy"

# now switch back to Default state
s.state nil
s.do_something  #=> "stares at the ceiling"

s.state :Angry

# what state are we in?
puts s.state

# pass a block to state transition
puts "passing a block"
s.state :Happy do 
    s.do_something; s.do_something; s.do_something 
end


puts "**********************"
puts "Now Testing SampleChild"
# in Default state
sc.do_something  #=> "stares at the ceiling"

# now switch to Happy state
sc.state :Happy
sc.do_something  #=> "Pets a puppy"

# now switch to Angry state
sc.state Sample::Angry
sc.do_something  #=> "Kicks a puppy"

# now switch back to Default state
sc.state nil
sc.do_something  #=> "stares at the ceiling"

sc.state :Angry

# what state are we in?
puts sc.state

# pass a block to state transition
puts "passing a block"
sc.state :Happy do
    sc.do_something; sc.do_something; sc.do_something
end



