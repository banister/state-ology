require 'states'

class Object
    def meta
        class << self; self; end
    end
end


# just a sample of how to use it
class Fren
    include StateModule
    
    state(:John) {
        def state_entry; puts "entering John state"; end
        
        def hello
            puts "John hello"
        end
        
        def state_exit; puts "exiting John state"; end
    }
    
    state(:Carl) {
        def state_entry; puts "entering Carl state"; end
        
        def hello
            puts "Carl hello"
        end
        
        def state_exit; puts "exiting Carl state"; end
    }
        
    # default state methods go here
    def hello
        puts "Default hello"
    end
        
end


f = Fren.new

puts "Carl state:\n"
f.state :Carl
f.hello
puts "ancestors: "
puts f.meta.ancestors

puts "John state:\n"
f.state :John
f.hello
puts "ancestors: "
puts f.meta.ancestors

puts "Default state:\n"
f.state :Default
f.hello
puts "ancestors: "
puts f.meta.ancestors

f.state :John

puts "state is Default? #{f.state?(:Default)}"

puts "the current state is #{f.state}"


