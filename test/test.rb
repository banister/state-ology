require 'test/unit'
require '../lib/stateology'

class Object
    def meta
        class << self; self; end
    end
end

class ParentState
    include Stateology
    attr_reader :state_entry_check
    attr_reader :state_exit_check
    
    def state_entry
        @state_entry_check = "entry_nil"
    end
    
    def state_exit
        @state_exit_check = "exit_nil"
    end
    
    state(:State1) {
    
        def state_entry
            @state_entry_check = "entry_state1"
        end
        
        def act
            1
        end
        
        def state1_act
            1
        end
        
        def state_exit  
            @state_exit_check = "exit_state1"
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
        assert_equal(nil, s.state_exit_check)
        assert_equal(nil, s.state_entry_check)
        assert_raises(NoMethodError) { s.state1_act }
    end
    
    def test_transition_from_nil_state
        s = ParentState.new
        assert_equal(0, s.act)
        assert_equal(nil, s.state_exit_check)
        assert_equal(nil, s.state_entry_check)
        s.state :State1 
        assert_equal("exit_nil", s.state_exit_check)
        assert_equal("entry_state1", s.state_entry_check)        
        assert_equal(1, s.act)
    end
    
    def test_transition_to_nil_state
        s = ParentState.new
        s.state :State1
        assert_equal(1, s.act)                  
        s.state nil
        assert_equal("exit_state1", s.state_exit_check)
        assert_equal("entry_nil", s.state_entry_check)
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
    
    def test_cant_transition_to_nested_from_nil             
      s = ParentState.new                               
      assert_raises(NameError){  s.state(:State1_nested1) }
    end                                                 

    
    def test_nested_state
        s = ParentState.new
        s.state :State1
        s.state :State1_nested
        assert_equal(1.5, s.act)
        assert_equal(1, s.state1_act)
        s.state nil
        assert_raises(NoMethodError) { s.state1_act }
        assert_equal(0, s.act)
    end
    
    def test_state_getter
      s = ParentState.new
      assert_equal(nil, s.state)
      
      s.state :State1
      assert_equal(:State1, s.state)
      
      s.state :State1_nested
      assert_equal(:State1_nested, s.state)
    end

    def test_state_compare
      s = ParentState.new
      assert_equal(true, s.state?(nil))
      
      s.state :State1
      assert_equal(false, s.state?(nil))
      assert_equal(true, s.state?(:State1))
      
      s.state :State1_nested
      assert_equal(false, s.state?(:State1))
      assert_equal(true, s.state?(:State1_nested))
      
      s.state nil
      assert_equal(true, s.state?(nil))
    end

    def test_state_defined_on_singleton
      s = ParentState.new
      
      class << s
        state(:Sing_state) { 
          def state_entry
            @state_entry_check = "sing_entry"
          end
          
          def act
            99
          end

          def state_exit
            @state_exit_check = "sing_exit"
          end
        }
      end

      assert_equal(0, s.act)
      
      s.state :Sing_state
      
      # test the getter
      assert_equal(:Sing_state, s.state)

      # test state_entry
      assert_equal("sing_entry", s.state_entry_check)
      
      # test the act function
      assert_equal(99, s.act)

      # test state compare
      assert_equal(true, s.state?(:Sing_state))
      
      s.state nil

      # test state_exit
      assert_equal("sing_exit", s.state_exit_check)
            
    end

end 
        
        
        
        
        
        
    
    
    
        
    
    
