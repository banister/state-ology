Stateology
==========

*Clean and fast Object state transitions in Ruby using the Mixology C extension.*

Supports:
* Dynamic switching between states (mixing and unmixing modules)
* Clean DSL-style syntax 
* Optional state\_entry() and state\_exit() hooks for each state (automatically called upon state entry and exit)
* support for subclassing of classes that include Stateology (see below)
* support for nested states, i.e states defined within other states

Use as in the following:

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
        
        # methods declared outside a 'state' are not part of any state
        
        def state_entry
            puts "entering Default state"
        end
        
        def do_something
            puts "stares at the ceiling"
        end
        
        def state_exit
            puts "exiting Default state"
        end
        
        # if we want the state_entry to run on instantiation
        # we must call it from the initialize method
        def initialize
            state_entry
        end
    
    end

    s = Sample.new

    # in no state
    s.do_something  #=> "stares at the ceiling"

    # now switch to Happy state
    s.state :Happy
    s.do_something  #=> "Pets a puppy"

    # now switch to Angry state
    s.state :Angry
    s.do_something  #=> "Kicks a puppy"

    # now switch back to no state
    s.state nil
    s.do_something  #=> "stares at the ceiling"

UPDATE:

* made it so subclasses can inherit states from their superclasses e.g

    class A
        include Stateology
        
        state(:Happy) {
            def state_entry
                puts "entering Happy state"
            end
            
            def hello
                puts "hello from A"
            end
        }
    end

    class B < A
        state(:Happy) {
            def hello
                puts "hello from B"
            end
        }
    end

    b = B.new

    b.state :Happy
    #=> "entering Happy state"

    b.hello
    #=> "hello from B"

* prior behaviour was for state\_entry not to exist in class B as Happy module from class A was overwritten by the new Happy module in B
* how does this fix work? the Happy module in B just includes any extant Happy module accessible in B




A FEW THINGS TO NOTE
--------------------

* When an object is instantiated it begins life in no state and only ordinary instance methods are accessible (The ordinary instance methods are those defined outside of any state() {} block)

* The ordinary instance methods are available to any state so long as they are not overridden by the state.

* To change from any given state to 'no state' pass nil as a parameter to the state method
e.g s.state nil

* 'no state', while not a state, may nonetheless have state\_entry() and state\_exit() methods; and these methods will be invoked on 'entry' and exit from 'no state'

* The state\_entry method for 'no state' is not automatically called on object instantiation. If you wish state\_entry to run when the object is instantiated invoke it in the initialize() method.

* The state\_entry method can also accept parameters:
e.g s.state :Happy, "hello"
In the above the string "hello" is passed as a parameter to the state\_entry() method of the Happy state.

* The #state method can accept either a Symbol (e.g :Happy) or a Module (e.g Happy or Sample::Happy). The following are equivalent:
s.state :Happy #=> change state to Happy

* The #state method can take a block; the block will be executed after the successful change of state:
e.g s.state(:Happy) { s.hello }    #=> hello method invoked immediately after change of state as it's in the block

s.state Sample::Happy #=> equivalent to above (note the fully qualified name; as Happy is a module defined under the Sample class)

* alternatively; if the #state method is invoked internally by another instance method of the Sample class then a fully qualified module name is not required:
state Happy #=> Fully qualified module name not required when #state invoked in an instance method

* The #state method can also act as a 'getter' method when invoked with no parameters. It will return the current state name in Symbol form (e.g :Happy)

* The #state\_mod method works similarly to the #state 'getter' except it returns the Module representing the current state (e.g Sample::Happy)

* The #state?(state\_name) returns boolean true if the current state is equal to state\_name, and false if not. state\_name can be either a Module or a Symbol


