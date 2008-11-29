begin
    require 'rubygems'
rescue LoadError
    # do nothing
end

require 'mixology'

module Stateology
    VERSION = "0.1.5"
    # alternative to 'nil'
    Default = nil

    # bring in class methods on include
    def self.included(c)
        c.extend(SM_Class_Methods)
    end

    # class methods
    module SM_Class_Methods
        def state(name, &block)      
            m = Module.new

            # if the state is defined further up the chain then "inherit it"
            if constants.include?(name.to_s) && !const_defined?(name) then
            
                # if constant not defined here then must be inherited
                inherited_state = const_get(name)
            
                # ignore if the constant is not a module                                
                m.send(:include, inherited_state) if Module === inherited_state                                                
            
            end
                        
            # bring Stateology into the module so we can create nested states
            m.send(:include, Stateology)   
            
            # now we've included Stateology we can eval the block
            m.module_eval(&block)
                  

            const_set(name, m)     
            
        end
    end
    
    # strip the class path and return just the constant name, i.e Hello::Fren -> Fren
    def __elided_class_path(sym)
        "#{sym}".split(/::/).last.intern
    end
    
    def __sym_to_mod(sym)
        class << self; self; end.const_get(sym)
    end
    
    def __mod_to_sym(mod)
        mod.name.to_sym
    end
    
    # is state_name a nested state?
    def __nested_state?(new_state)
    
        # test is: 
        # (1) are we in a state? (non nil)
        # (2) is the new state a state? (non nil)
        # (3) is the new state defined under the current state? (i.e it's nested)
        @__SM_nesting.first && 
        new_state && 
        @__SM_nesting.first.const_defined?(__elided_class_path(__mod_to_sym(new_state)))
    end
        
    
    # instance methods   
    def __state_epilogue
                        
        @__SM_nesting.each do |old_state|    
            raise NameError if !(Module === old_state) && old_state != nil
              
            begin
                state_exit()
            rescue NoMethodError
                # do nothing
            end
            puts "exiting #{old_state}"
            if old_state then unmix(old_state) end
        end
    end
        
    def __state_prologue(new_state, state_args, &block)
    
        # ensure that the constant is a module
        raise NameError if !(Module === new_state) && new_state != nil
        
        puts "entering state #{new_state}"
        
        # only mixin if non-nil (duh)
        if new_state then extend(new_state) end
        
        begin  
            state_entry(*state_args, &block)                
        rescue NoMethodError
            # do nothing
        end
        
    end
        
    def state(*state_args, &block)
        @__SM_nesting ||= []    
                                       
        # behave as getter
        if state_args.empty? then            
            return @__SM_nesting.first ? __elided_class_path(__mod_to_sym(@__SM_nesting.first)) : nil
        end
        
        # behave as setter (only care about first argument)
        state_name = state_args.shift
        
        # if we receive a Symbol convert it to a constant
        if Symbol === state_name then
            state_name = __sym_to_mod(state_name)
        end
                
        # prevent unnecessary state transitions
        return if @__SM_nesting.first== state_name
          
        # exit old state only if the new state is not nested within it              
        if not __nested_state?(state_name) then 
            __state_epilogue                
            @__SM_nesting = []                                            
        end
                            
        # enter new state                       
        __state_prologue(state_name, state_args, &block)   
                        
        # update the stack of current states 
         @__SM_nesting.unshift(state_name)
                
        # return value is the current state
        @__SM_nesting.first
        
        rescue NameError
            raise NameError, "#{state_name} not a valid state" 
                                        
    end
    
    # is the current state equal to state_name?
    def state?(state_name)
    
        # if we receive a Symbol convert it to a constant
        if Symbol === state_name then
            state_name = class << self; self; end.const_get(state_name)
        end
        
        raise NameError if !(Module === state_name) && state_name != nil
        
        state_name == @__SM_nesting.first
        
        rescue NameError
            raise NameError, "#{state_name} not a valid state" 
                                                            
    end
    
    # return the current state as a module
    def state_mod
        @__SM_nesting.first
    end
                   
    private :__state_prologue, :__state_epilogue
        
end


