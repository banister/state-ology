begin
    require 'rubygems'
rescue LoadError
    # do nothing
end

require 'mixology'


module Stateology
    
    # alternative to 'nil'
    Default = nil

    # bring in class methods on include
    def self.included(c)
        c.extend(SM_Class_Methods)
    end

    # class methods
    module SM_Class_Methods
        def state(name, &block)      
         
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
                                            
        # behave as getter
        if(state_args.empty?) then            
            return @__SM_cur_state ? "#{@__SM_cur_state}".split(/::/).last.intern : nil
        end
        
        # behave as setter (only care about first argument)
        state_name = state_args.shift
        
        # if we receive a Symbol convert it to a constant
        if(Symbol === state_name) then
            state_name = self.class.const_get(state_name)
        end
                
        # prevent unnecessary state transitions
        return if(@__SM_cur_state == state_name)
          
        # exit old state                                   
        __state_epilogue(@__SM_cur_state)                   
        
                    
        # enter new state               
        __state_prologue(state_name, state_args)   
        
        # update the current state variable    
        @__SM_cur_state = state_name
        
        rescue NameError
            raise NameError, "#{state_name} not a valid state" 
                                        
    end
    
    # is the current state equal to state_name?
    def state?(state_name)
    
        # if we receive a Symbol convert it to a constant
        if(Symbol === state_name) then
            state_name = self.class.const_get(state_name)
        end
        
        raise NameError if(!(Module === state_name) && state_name != nil)
        
        state_name == @__SM_cur_state
        
        rescue NameError
            raise NameError, "#{state_name} not a valid state" 
                                                            
    end
    
    # return the current state as a module
    def state_mod
        @__SM_cur_state
    end
                   
    private :__state_prologue, :__state_epilogue
end


