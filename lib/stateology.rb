# stateology.rb
# (C) John Mair 2008
# This program is distributed under the terms of the MIT License
# now supports BOTH ruby 1.8.6 and ruby 1.9.1

begin
    require 'rubygems'
rescue LoadError
    # do nothing
end

require 'mixology'

module Stateology
    VERSION = "0.2.0"

    # alternative to 'nil'
    Default = nil

    # bring in class methods on include
    def self.included(c)
        c.extend(SM_Class_Methods)
    end


    # class methods
    module SM_Class_Methods
        def state(name, &block)
            
            if RUBY_VERSION =~ /1.9/
                    pram = [false]
                else
                    pram = []
            end

            # if const is defined here then module_eval
            if const_defined?(name, *pram) then
                m = self.const_get(name)
                m.module_eval(&block)
            else

                m = Module.new
                # if the state is defined further up the chain then "inherit it"
                if constants.include?(name) || constants.include?(name.to_s) then
                    # if constant not defined here then must be inherited
                    inherited_state = const_get(name)

                    # ignore if the constant is not a module
                    m.send(:include, inherited_state) if inherited_state.instance_of?(Module)
                end

                m.send(:include, Stateology)
                m.module_eval(&block)

                const_set(name, m)
            end
        end
    end

    # strip the class path and return just the constant name, i.e Hello::Fren -> Fren
    def __elided_class_path(sym)
        sym.to_s.split(/::/).last.to_sym
    end

    def __sym_to_mod(sym)
        class << self; self; end.const_get(sym)
    end

    def __mod_to_sym(mod)
        
        # weird case where module does not have name (i.e when a state created on the eigenclass)
        if mod.name == nil || mod.name == "" then
            class << self; self; end.constants.each do |v|
                return v.to_sym if __sym_to_mod(v.to_sym) == mod
            end
            return :ConstantNotDefined
        end

        mod.name.to_sym
    end

    # is state_name a nested state?
    def __nested_state?(new_state)

        if RUBY_VERSION =~ /1.9/
            pram = [false]
        else
            pram = []
        end

        # test is:
        # (1) are we currently in a state? (non nil)
        # (2) is the new state a state? (non nil)
        # (3) is the new state defined under the current state? (i.e it's nested)
        __current_state &&
            new_state &&
            __current_state.const_defined?(__elided_class_path(__mod_to_sym(new_state)), *pram)
    end

    # instance methods
    def __state_epilogue

        @__SM_nesting.each do |old_state|
            raise NameError if !old_state.instance_of?(Module) && old_state != nil

            begin
                state_exit()
            rescue NoMethodError
                # do nothing
            end

            if old_state then unmix(old_state) end
        end
        @__SM_nesting = []
    end

    def __state_prologue(new_state, state_args, &block)

        # ensure that the constant is a module
        raise NameError if !new_state.instance_of?(Module) && new_state != nil

        # only mixin if non-nil (duh)
        if new_state then extend(new_state) end

        begin
            state_entry(*state_args, &block)
        rescue NoMethodError
            # do nothing
        end

    end

    def __validate_state_name(state_name)
        # if we receive a Symbol convert it to a constant
        if Symbol === state_name then
            state_name = __sym_to_mod(state_name)
        end

        raise NameError if state_name && !state_name.instance_of?(Module)

        state_name
    end

    def __state_transition(new_state, state_args, &block)
        # preven unnecessary state transition
        return if __current_state == new_state

        # get rid of state_name from arg list
        state_args.shift

        # exit old state only if the new state is not nested within it
        __state_epilogue unless __nested_state?(new_state)
        __state_prologue(new_state, state_args, &block)

        @__SM_nesting.unshift(new_state)
    end

    def __state_getter
        __current_state ? __elided_class_path(__mod_to_sym(__current_state)) : nil
    end

    def __current_state
        @__SM_nesting ||= [nil]
        @__SM_nesting.first
    end

    def state(*state_args, &block)

        # behave as getter
        if state_args.empty? then
            return __state_getter
        end

        new_state = __validate_state_name(state_args.first)

        __state_transition(new_state, state_args, &block)

        # return value is the current state
        __current_state

    rescue NameError
        raise NameError, "#{new_state} not a valid state"

    end

    # is the current state equal to state_name?
    def state?(state_name)

        state_name = __validate_state_name(state_name)

        # compare
        state_name == __current_state

    rescue NameError
        raise NameError, "#{state_name} not a valid state"

    end

    # return the current state as a module
    def state_mod
        __current_state
    end
    
    alias_method :state=, :state

    private :__state_prologue, :__state_epilogue, :__elided_class_path, :__mod_to_sym, :__sym_to_mod,
    :__nested_state?, :__current_state, :__validate_state_name, :__state_transition, :__state_getter

end


