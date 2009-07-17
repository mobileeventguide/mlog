#IMPORTANT!

#The file that starts the whole mess, needs to require this file!

#Because, this file is used to fix the require paths
libname = "fixpath.rb"
#get our current working dir
if File.exist? libname
  libpath = File.dirname(File.expand_path(libname)).to_s
else 
  puts "FATAL_LIB_ERROR: #{libname} could not be located, exiting, sorry."
  exit(0) #rude, i know, comment out if you don't care
end
#now we fix the ruby LOAD_PATH $:
$: << libpath
#debug:
#puts $: #display LOAD_PATH
