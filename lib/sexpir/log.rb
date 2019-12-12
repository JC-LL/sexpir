module Log

  def indent v,str
    @indent=v
    puts " "*@indent+str.to_s
  end

  def log msg
    puts msg
    #log_dbg msg
  end

  def log_dbg msg
    puts msg
    #$log.puts msg
  end

  def step
    log "press any key"
    key=$stdin.gets
  end
end
