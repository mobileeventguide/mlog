module MLog
  require 'logger'
  require 'awesome_print'
  
  # q&d config for additional loggers
  class Configuration
    @@log_paths = {}

    def self.log_paths
      @@log_paths
    end

    def self.add_log_path key, log_path
      @@log_paths[key] = log_path
    end
  end

  attr_accessor :mlog_debugname, :mlogs

  #setup default logger
  def mlog_logger_check
    if @mlogs.nil?
      @debugname = self.class if @debugname.nil? #only used to inform the user
      @mlogs = {:default => Logger.new(STDOUT)}
      # add file loggers if they were configured
      unless MLog::Configuration.log_paths.blank?
        MLog::Configuration.log_paths.each do |key,log_path|
          @mlogs[key] = Logger.new(log_path, 'daily')
        end
      end
      @mlogs.each {|k, ml| ml.level = Logger::DEBUG}
      @mlogs.each {|k, ml| ml.datetime_format = "%H:%M:%S"} #useful for debugging
      @tracing = false
      #enable tracing
      if @tracing
        mlog_enable_silent_trace
      end
    end
  end

  #set the debug level
  def mlog_log_level level=""
    @mlogs.each {|k, ml| ml.level = Logger::DEBUG if level.eql? "debug"}
    @mlogs.each {|k, ml| ml.level = Logger::INFO if level.eql? "info"}
    @mlogs.each {|k, ml| ml.level = Logger::WARN if level.eql? "warning"}
    @mlogs.each {|k, ml| ml.level = Logger::ERROR if level.eql? "error"}
    @mlogs.each {|k, ml| puts "[#{k.to_s}] LOG-LEVEL: #{ml.level}"}
  end

  #error message
  def elog text="error"
    mlog_logger_check #check if logger is setup
    meth_trace = mlog_meth_trace.to_s
    @mlogs.each {|k, ml| ml.error "[#{Time.now}] #{@debugname}.#{meth_trace}: #{text.to_s}"}
  end

  #warning
  def wlog text="warning"
    mlog_logger_check #check if logger is setup
    meth_trace = mlog_meth_trace.to_s
    @mlogs.each {|k, ml| ml.warn "[#{Time.now}] #{@debugname}.#{meth_trace}: #{text.to_s}"}
  end

  #info message
  def ilog text="info"
    mlog_logger_check #check if logger is setup
    meth_trace = mlog_meth_trace.to_s
    @mlogs.each {|k, ml| ml.info "[#{Time.now}] #{@debugname}.#{meth_trace}: #{text.to_s}"}
  end

  #debug message
  def dlog text="debug"
    mlog_logger_check #check if logger is setup
    meth_trace = mlog_meth_trace.to_s
    @mlogs.each {|k, ml| ml.debug "[#{Time.now}] #{@debugname}.#{meth_trace}: #{text.to_s}"}
  end

  #debug message
  def alog text="awesomeness"
    mlog_logger_check #check if logger is setup
    meth_trace = mlog_meth_trace.to_s
    @mlogs.each {|k, ml| ml.debug "[#{Time.now}] #{@debugname}.#{meth_trace}: ap=>"; ml.ap text}
  end

  #get method call trace
  def mlog_meth_trace
    last_meth_name = "notrace"
    skip = 2 #indicates how many items we skip in the execution stack trace
    call_trace = caller(skip)
    regexp = /\`.*?\'/
      last_meth = call_trace[0][regexp]
    last_meth_name = last_meth.delete("\`") unless last_meth.nil?
    last_meth_name = last_meth_name.delete("\'") unless last_meth_name.nil?
    return last_meth_name
  end

  #check if we or an object are ready to log
  def log? object=self
    has_log = (defined? object.log?).eql? "method"
    dlog "object of class: #{object.class} is rock'n'log." if has_log
    return has_log
  end

  #enable vm wide tracing
  def mlog_enable_trace event_regex = /^(call)/
    #this is the Kernel::set_trace_func that we overwrite
    trace_func = Proc.new do |event, file, line, id, binding, classname|
      if (event =~ event_regex)
        e = {:event=>event,:file=>file,:line=>line,:id=>id,:binding=>binding,:classname=>classname}
        mlog_trace_event_callback e 
      end
    end
    set_trace_func trace_func
    return
  end

  #enable vm wide silent tracing
  def mlog_enable_silent_trace event_regex = /^(call)/
    #this is the Kernel::set_trace_func that we overwrite
    trace_func = Proc.new {|event, file, line, id, binding, classname|}
    set_trace_func trace_func
    return
  end

  #disable vm wide tracing
  def mlog_disable_trace
    set_trace_func nil
  end

  #fires when there is a new trace event
  def mlog_trace_event_callback trace_event
    puts "new trace:"
    trace_event.each { |n,t| puts "#{n}: #{t.inspect}"}  
  end
  
end
  
#finally we just include ourselves, a little dirty ... what the hell :)
include MLog
