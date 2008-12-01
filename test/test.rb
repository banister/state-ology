require 'test/unit'
require '../lib/stateology'

class Object
    def meta
        class << self; self; end
    end
end

class ParentState
    include Stateology
    attr_reader :state_val
    attr_reader :xstate_val
    
    def state_entry
        @state_val = "entry_nil"
    end
    
    def state_exit
        @xstate_val = "exit_nil"
    end
    
    state(:State1) {
    
        def state_entry
            @state_val = "entry_state1"
        end
        
        def act
            1
        end
        
        def state1_act
            1
        end
        
        def state_exit  
            @xstate_val = "exit_state1"
        end
        
        state(:State1_nested) {
            def state_entry(&block) 
                puts "balls-deep in State1_nested!"
                if block then yield end
            end
            def act
                1.5
            end
        }
    }
    
    state(:State2) {
        def act
            2
        end
        
        def state2_act
            2
        end
    }
    
    
    def act
        0
    end
end

class ChildState < ParentState
    state(:State1) {
        def act_child
            1
        end
    }
    
    state(:State2) {
        def act_child
            2
        end
    }
    
    def act
        0
    end         
end

class StateologyTest < Test::Unit::TestCase
    puts "testing Stateology #{Stateology::VERSION}"

    def test_nil_state
        s = ParentState.new
        assert_equal(0, s.act)
        assert_equal(nil, s.xstate_val)
        assert_equal(nil, s.state_val)
        assert_raises(NoMethodError) { s.state1_act }
    end
    
    def test_transition_from_nil_state
        s = ParentState.new
        assert_equal(0, s.act)
        assert_equal(nil, s.state_val)
        assert_equal(nil, s.xstate_val)
        s.state :State1 
        assert_equal("exit_nil", s.xstate_val)
        assert_equal("entry_state1", s.state_val)        
        assert_equal(1, s.act)
    end
    
    def test_transition_to_nil_state
        s = ParentState.new
        s.state :State1
        assert_equal(1, s.act)                  
        s.state nil
        assert_equal("exit_state1", s.xstate_val)
        assert_equal("entry_nil", s.state_val)
        assert_equal(0, s.act)
        assert_raises(NoMethodError) { s.state1_act }
    end
    
    def test_transition_from_state1_to_state2
        s = ParentState.new
        s.state :State1
        assert_equal(1, s.act)
        assert_raises(NoMethodError) { s.state2_act }
        s.state :State2
        assert_equal(2, s.act)
        assert_raises(NoMethodError) { s.state1_act }
    end
    
    def test_inheritance_of_state
        s = ChildState.new
        s.state :State1
        
        # testing inherited state methods
        assert_equal(1, s.act)
        assert_equal(1, s.state1_act)
        
        # testing own method
        assert_equal(1, s.act_child)
    end
    
    def test_nested_state
        s = ParentState.new
        s.state :State1
        s.state :State1_nested do puts "BLOCK PASSED TO STATE1_NESTED" end
        assert_equal(1.5, s.act)
        assert_equal(1, s.state1_act)
        s.state nil
        assert_raises(NoMethodError) { s.state1_act }
        assert_equal(0, s.act)
    end
    
       
end 
        
        
        
        
        
        
    
    
    
        
    
    