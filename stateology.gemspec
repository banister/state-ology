Gem::Specification.new do |s|
   s.name = %q{stateology}
   s.version = "0.2.1"
   s.date = %q{2009-6-13}
   s.authors = ["John Mair"]
   s.email = %q{jrmair@gmail.com}
   s.summary = %q{Clean and fast Object state transitions in Ruby using the Mixology C extension.}
   s.homepage = %q{http://banisterfiend.wordpress.com}
   s.description = %q{Clean and fast Object state transitions in Ruby using the Mixology C extension }
   s.files = [ "README.markdown", "LICENSE", "lib/stateology.rb", "sample.rb", "CHANGELOG", "test/test.rb"]
   s.add_dependency("mixology", ">= 0.1.0")
end 
