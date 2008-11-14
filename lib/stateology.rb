begin
    require 'rubygems'
rescue LoadError
    # do nothing
end

require 'mixology'


module Stateology

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
        raise NameError if(!(Module === old_state) && old_state != nil)
               
        begin
            state_exit()
        rescue NoMethodError
            # do nothing
        end
        
        if old_state then unmix(old_state) end
    end
        
    def __state_prologue(new_state, state_args)
    
        # ensure that the constant is a module
        raise NameError if(!(Module === new_state) && new_state != nil)
        
        # only mixin if 
        if new_state then mixin(new_state) end
        
        begin  
            state_entry(*state_args)                
        rescue NoMethodError
            # do nothing
        end
        
    end
        
    def state(*state_args)
    
        @__SM_cur_state ||= :Default
                                
        # behave as getter
        if(state_args.empty?) then
            return @__SM_cur_state 
        end
        
        # behave as setter (only care about first argument)
        state_name = state_args.shift
        
        # prevent unnecessary state transitions
        return if(@__SM_cur_state == state_name)
          
        # exit old state   
        s = @__SM_cur_state != :Default ? self.class.const_get(@__SM_cur_state) : nil                                  
        __state_epilogue(s)                   
        
                    
        # enter new state       
        s = state_name != :Default ? self.class.const_get(state_name) : nil       
        __state_prologue(s, state_args)   
        
        # update the current state variable    
        @__SM_cur_state = state_name
        
        rescue NameError
            raise StateNameError, "#{state_name} not a valid state" 
                                        
    end
    
    def state?(state_name)
        @__SM_cur_state ? state_name == @__SM_cur_state : state_name == :Default
    end
           
    private :__state_prologue, :__state_epilogue
end


