begin
    require 'rubygems'
rescue LoadError
    # do nothing
end

require 'mixology'


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
            state_exit()
        rescue NoMethodError
            # do nothing
        end
        unmix(old_state)
    end
        
    def __state_prologue(new_state, state_args)
    
        # ensure that the constant is a module
        raise NameError if(!(Module === new_state))
        
        mixin(new_state)
        begin
            state_entry(*state_args)
        rescue NoMethodError
            # do nothing
        end
    end
        
    def state(*state_args)
                                
        # behave as getter
        if(state_args.empty?) then
            return @__SM_cur_state ? @__SM_cur_state : :Default
        end
        
        # behave as setter; only care about first argument
        state_name = state_args.shift
        
        # prevent unnecessary state transitions
        return if(@__SM_cur_state == state_name || (state_name == :Default && !@__SM_cur_state))
          
        # only need to call epilogue if in a state other than Default
        if(@__SM_cur_state) then        
            s = self.class.const_get(@__SM_cur_state)                                   
            __state_epilogue(s)           
        end
        
        # Default state is the same as no mixins
        if(state_name == :Default) then 
            @__SM_cur_state = nil           
            return
        end
        
        # state prologue        
        s = self.class.const_get(state_name)              
        __state_prologue(s, state_args)        
        @__SM_cur_state = state_name
        
        rescue NameError
            raise StateNameError, "#{state_name} not a valid state" 
                                        
    end
    
    def state?(state_name)
        @__SM_cur_state ? state_name == @__SM_cur_state : state_name == :Default
    end
           
    private :__state_prologue, :__state_epilogue
end


