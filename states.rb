begin
    require 'rubygems'
rescue LoadError
    # do nothing
end

require 'mixology'

class Object
    def meta
        class << self; self; end
    end
end

module StateModule

    # custom Exception
    class StateNameError < NameError; end

    # bring in class methods on include
    def self.included(c)
        c.extend(SM_Class_Methods)
    end

    # class methods
    module SM_Class_Methods
        def state(name, &block)      
        
            if(name == :Default) then
                class_eval &block
                return
            end
                  
            const_set(name, Module.new(&block))
                        
        end
    end
    
    # instance methods
    
    def __state_epilogue(old_state) 
    
        # ensure that the constant is a module
        raise NameError if(!(Module === old_state))
        
        begin    
            state_exit
        rescue NoMethodError
            # do nothing
        end
        unmix(old_state)
    end
        
    def __state_prologue(new_state)
    
        # ensure that the constant is a module
        raise NameError if(!(Module === new_state))
        
        mixin(new_state)
        begin
            state_entry
        rescue NoMethodError
            # do nothing
        end
    end
        
    def state(*state_name)
    
        raise ArgumentError, "wrong number of arguments; expected 1 or 0." if(state_name.size > 1)
    
        # behave as getter
        if(state_name.empty?) then
            return @__SM_cur_state ? @__SM_cur_state : :Default
        end
        
        # behave as setter; only care about first argument
        state_name = state_name.first
          
        # only need to call epilogue if in a state other than Default
        if(@__SM_cur_state) then        
            s = self.class.const_get(@__SM_cur_state)                                   
            __state_epilogue(s)
            
        end
        
        # Default state is already mixed in
        if(state_name == :Default) then 
            @__SM_cur_state = nil           
            return
        end
        
        # state prologue        
        s = self.class.const_get(state_name)              
        __state_prologue(s)        
        @__SM_cur_state = state_name
        
        rescue NameError
            raise StateNameError, "#{state_name} not a valid state" 
                                        
    end
    
    def state?(state_name)
        @__SM_cur_state ? state_name == @__SM_cur_state : state_name == :Default
    end
           
    private :__state_prologue, :__state_epilogue
    
end


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

#f.state :Yo

puts "state is #{f.state?(:Default)}"

puts f.state



