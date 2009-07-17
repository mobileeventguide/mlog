require 'logger'

#little happy logger module
module Rofl

  attr_accessor :debugname,:logger
  
  #check if there already is a logger, kind of a constructor
  def rofl_logger_check
    if @logger.nil?
      #to stop output from getting messy, we use a logger
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      #@logger.datetime_format = "%Y-%m-%d %H:%M:%S" #useful for logging to a file
      @logger.datetime_format = "%H:%M:%S" #useful for debugging
      @debugname = self.class if @debugname.nil? #only used to inform the user
      @tracing = false
      #enable tracing
      if @tracing
        require 'rofl_trace'
        include RoflTrace
        rofl_enable_trace
      end
    end
  end
  #error message
  def elog text="error" 
    rofl_logger_check #check if logger is setup
    @logger.error "#{@debugname}.#{rofl_meth_trace}: #{text.to_s}"
  end
  #warning
  def wlog text="warning"
    rofl_logger_check #check if logger is setup
    @logger.warning "#{@debugname}.#{rofl_meth_trace}: #{text.to_s}"
  end
  #info message
  def ilog text="info"
    rofl_logger_check #check if logger is setup
    @logger.info "#{@debugname}.#{rofl_meth_trace}: #{text.to_s}"
  end
  #debug message
  def dlog text="debug"
    rofl_logger_check #check if logger is setup
    @logger.debug "#{@debugname}.#{rofl_meth_trace}: #{text.to_s}"
  end
  #get method call trace
  def rofl_meth_trace
    skip = 2 #indicates how many items we skip in the execution stack trace
    call_trace = caller(skip)
    last_meth = call_trace[0][/\`.*?\'/]
    last_meth_name = last_meth.delete("\`").delete("\'") #what was the right string method for this?
    return last_meth_name
  end
  #check if we or an object are ready to rofl
  def rofl? object=self
    has_rofl = (defined? object.rofl?).eql? "method"
    dlog "object of class: #{object.class} is rock'n'rofl." if has_rofl
    return has_rofl
  end
end
#finally we just include ourselves, a little dirty ... what the hell :)
include Rofl
#and check, if we're ready to go
rofl_logger_check
