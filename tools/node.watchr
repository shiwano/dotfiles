# -*- encoding: utf-8 -*-
p ARGV
$fail_fast = ARGV.include? "fail-fast"
$backtrace = ARGV.include? "backtrace"

# Run me with:
#
#   $ watchr specs.watchr

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
def all_spec_files
  Dir['test/**/*_spec.js*']
end

def run_spec_matching(thing_to_match)
  p thing_to_match
  matches = all_spec_files.grep(/#{thing_to_match}/i)
  p matches
  if matches.empty?
    puts "Sorry, thanks for playing, but there were no matches for #{thing_to_match}"
  else
    run matches.join(' ')
  end
end

def mocha(file)
  %|mocha #{file} --compilers coffee:coffee-script -r should --reporter spec --ignore-leaks|
end

def run(files_to_run)
  puts("Running: #{files_to_run}")
  cmd = mocha(files_to_run)
  p cmd
  system cmd
  no_int_for_you
end

def run_all_specs
  run(all_spec_files.join(' '))
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch('^test/(.*)_spec\.js*')   { |m| run_spec_matching(m[1]) }
watch('^lib/(.*)\.js*')         { |m| run_spec_matching(m[1]) }
#watch('^spec/spec_helper\.rb') { run_all_specs }
#watch('^spec/support/.*\.rb')   { run_all_specs }
# --------------------------------------------------
# Signal Handling
# --------------------------------------------------

def no_int_for_you
  @sent_an_int = nil
end

Signal.trap 'INT' do
  if @sent_an_int then
    puts "   A second INT?  Ok, I get the message.  Shutting down now."
    exit
  else
    puts "   Did you just send me an INT? Ugh.  I'll quit for real if you do it again."
    @sent_an_int = true
    Kernel.sleep 1.5
    run_all_specs
  end
end


# vim:filetype=ruby
