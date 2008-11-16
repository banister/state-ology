Gem::Specification.new do |s|
   s.name = %q{stateology}
   s.version = "0.1.0"
   s.date = %q{2008-11-14}
   s.authors = ["John Mair"]
   s.email = %q{jrmair@gmail.com}
   s.summary = %q{Clean and fast Object state transitions in Ruby using the Mixology C extension.}
   s.homepage = %q{http://banisterfiend.wordpress.com}
   s.description = %q{Clean and fast Object state transitions in Ruby using the Mixology C extension }
   s.files = [ "README", "LICENSE", "lib/stateology.rb", "sample.rb"]
   s.add_dependency("mixology", ">= 0.1.0")
end 
