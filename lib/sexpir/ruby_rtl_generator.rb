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
      filename=circuit.name.to_s+".rb"
      code.save_as filename
    end

    def visitCircuit circuit,args=nil
      code=Code.new
      code << "require 'ruby_rtl'"
      code.newline
      code << "include RubyRTL"
      code.newline
      code << "class #{circuit.name.capitalize} < Circuit"
      code.indent=2
      code << "def initialize"
      code.indent=4
      circuit.inputs.each{|input| code << input.accept(self)}
      circuit.outputs.each{|output| code << output.accept(self)}
      circuit.signals.each{|signal| code << signal.accept(self)}
      code.newline
      code << circuit.body.accept(self)
      code.indent=2
      code << "end"
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

    # === statements ===
    def visitBody body,args=nil
      code=Code.new
      body.stmts.each{|stmt| code << stmt.accept(self)}
      code
    end

    def visitCombinatorial comb,args=nil
      code=Code.new
      code << "combinatorial(#{comb.label}){"
      code.indent=2
      code << comb.body.accept(self)
      code.indent=0
      code << "}"
      code
    end
    def visitSequential seq,args=nil
      code=Code.new
      code << "sequential(#{seq.label}){"
      code.indent=2
      code << seq.body.accept(self)
      code.indent=0
      code << "}"
      code
    end

    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      rhs=assign.rhs.accept(self)
      "assign(#{lhs} <= #{rhs})"
    end

    def visitIf if_,args=nil
      cond=if_.cond.accept(self)
      code=Code.new
      code << "If(#{cond}){"
      code.indent=2
      code << if_.then.accept(self)
      if if_.else
        code.indent=0
        code << "Else{"
        code.indent=2
        code << if_.else.accept(self)
        code.indent=0
        code << "}"
      else
        code.indent=0
        code << "}"
      end
      code
    end

    def visitCase case_,args=nil
      expr=case_.expr.accept(self)
      code=Code.new
      code << "Case(#{expr}){"
      code.indent=2
      case_.whens.each do |when_|
        code << when_.accept(self)
      end
      code << case_.default.accept(self)
      code.indent=0
      code << "}"
      code
    end

    def visitWhen when_,args=nil
      expr=when_.expr.accept(self)
      code=Code.new
      code << "When(#{expr}){"
      code.indent=2
      code << when_.body.accept(self)
      code.indent=0
      code << "}"
      code
    end

    def visitDefault default_,args=nil
      code=Code.new
      code << "Else{"
      code.indent=2
      code << default_.body.accept(self)
      code.indent=0
      code << "}"
      code
    end

    # === component stuff ====
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
      op=SEXPIR_TO_RUBY_OP[binary.op] || binary.op
      "(#{lhs} #{op} #{rhs})"
    end

    def visitTerm term,args=nil
      term
    end

    def visitVar var,args=nil
      var.name
    end

    def visitConst const,args=nil
      const.value
    end

    def visitSlice slice,args=nil
      expr=slice.expr.accept(self)
      msb=slice.msb.accept(self)
      lsb=slice.lsb.accept(self)
      "#{expr}[#{msb}..#{lsb}]"
    end


  end
end
