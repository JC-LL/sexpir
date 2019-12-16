module Sexpir

  class Visitor

    def visitCircuit circuit,args=nil
      circuit.name
      circuit.inputs.each{|input| input.accept(self)}
      circuit.outputs.each{|output| output.accept(self)}
      circuit.signals.each{|signal| signal.accept(self)}
      circuit.body.accept(self)
    end

    def visitSignal sig,args=nil
      signal.name
      signal.type
    end

    def visitIo io,args=nil
      io.name
      io.type
    end

    def visitPort port,args=nil
      port.name
      port.type
    end

    def visitInput input,args=nil
      input.name
      input.type
    end

    def visitOutput output,args=nil
      output.name
      output.type
    end

    def visitBody body,args=nil
      body.stmts.each{|stmt| stmt.accept(self)}
    end

    def visitAssign assign,args=nil
      assign.lhs.accept(self)
      assign.rhs.accept(self)
    end

    def visitComponent component,args=nil
      name=component.name
      type=component.type
      "component #{name} => #{type}"
    end

    def visitConnect connect,args=nil
      connect.source
      connect.sink
    end

    #===========
    def visitExpression expr,args=nil
    end

    def visitBinary binary,args=nil
      binary.lhs.accept(self)
      binary.rhs.accept(self)
    end

    def visitTerm term,args=nil
      term
    end

    def visitVar var,args=nil
      var.name
    end

  end
end
