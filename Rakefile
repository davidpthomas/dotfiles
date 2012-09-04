#
# Utility to create dotfile symlinks in home directory
#

require 'rake'

desc "install dotfiles and symlinks in $HOME dir."
task :install do
  Dir['**/*'].each do |relfile|

    # skip helpers
    next if %w[Rakefile README.md].include? relfile

    to_file = File.join(Dir.getwd, relfile)
    to_filename = File.basename(to_file)

    from_file = File.join(ENV['HOME'], dot_filename(to_filename))
    from_filename = to_filename


    # skip dirs
    next if File.directory?(to_file) 

    if File.exists?(from_file)
      if !File.identical?(from_filename, to_filename)
        puts "> Skipping #{from_filename} - different and already exists"
      end
    else
      puts "* Created link #{from_file} ..."
      File.symlink(to_file, from_file)
    end
  end
end

def dot_filename(filename)
  ".#{filename}"
end
