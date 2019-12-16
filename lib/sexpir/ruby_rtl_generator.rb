require_relative 'log'
class Symbol
  def accept visitor,args=nil
    self
  end
end

module Sexpir
  class RubyRTLGenerator < Visitor
    include Log
    def generate circuit
      log "[+] generating RubyRTL '#{circuit.name}'"
      code=circuit.accept(self)
      puts code.finalize
    end

    def visitCircuit circuit,args=nil
      code=Code.new
      code << "require 'ruby_rtl'"
      code << "class #{circuit.name.capitalize} < Circuit"
      code.indent=2
      circuit.inputs.each{|input| code << input.accept(self)}
      circuit.outputs.each{|output| code << output.accept(self)}
      circuit.signals.each{|signal| code << signal.accept(self)}
      code.newline
      code << circuit.body.accept(self)
      code.indent=0
      code << "end"
      code
    end

    def gen_type(type)
      case num=type
      when Integer
        case num
        when 1
          return "bit"
        else
          return "bv#{num}"
        end
      else
        return type
      end
    end

    def visitSignal sig,args=nil
      sig.name
      type=gen_type(sig.type)
      "wire :#{sig.name} => :#{type}"
    end

    def visitIo io,args=nil
      io.name
      io.type
    end

    def visitPort port,args=nil
      comp=port.component_name
      name=port.name
      "#{comp}.#{name}"
    end

    def visitInput input,args=nil
      input.name
      input.type
      "input :#{input.name} => :#{input.type}"
    end

    def visitOutput output,args=nil
      output.name
      output.type
      "output :#{output.name} => :#{output.type}"
    end

    def visitBody body,args=nil
      code=Code.new
      body.stmts.each{|stmt| code << stmt.accept(self)}
      code
    end

    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      rhs=assign.rhs.accept(self)
      "assign(#{lhs} <= #{rhs})"
    end

    def visitComponent component,args=nil
      name=component.name
      type=component.type
      "component :#{name} => #{type.capitalize}"
    end

    def visitConnect connect,args=nil
      source=connect.source.accept(self)
      sink=connect.sink.accept(self)
      "connect #{source} => #{sink}"
    end

    #===========
    def visitExpression expr,args=nil
    end

    SEXPIR_TO_RUBY_OP={
      "and" => "&",
      "or"  => "|",
      "xor" => "^",
      "not" => "!",
    }
    def visitBinary binary,args=nil
      lhs=binary.lhs.accept(self)
      rhs=binary.rhs.accept(self)
      op=SEXPIR_TO_RUBY_OP[binary.op]
      "(#{lhs} #{op} #{rhs})"
    end

    def visitTerm term,args=nil
      term
    end

    def visitVar var,args=nil
      var.name
    end
  end
end
