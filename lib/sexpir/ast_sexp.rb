require_relative 'code'

class Symbol
  def sexp
    self
  end
end

module Sexpir

  class Circuit < Ast
    def sexp
      code=Code.new
      code << "(circuit #{name}"
      code.indent=2
      signals.each{|sig| code << sig.sexp}
      inputs.each{|input | code << input.sexp}
      outputs.each{|output| code << output.sexp}
      code.newline
      code << body.sexp
      code.indent=0
      code << ")"
      code.finalize
    end
  end

  class Signal < Ast
    def sexp
      "(signal  #{name} #{type})"
    end
  end

  class Port < Io
    def sexp
      "(port #{component_name} #{name})"
    end
  end

  class Input < Io
    def sexp
      "(input  #{name} #{type})"
    end
  end

  class Output < Io
    def sexp
      "(output #{name} #{type})"
    end
  end

  class Body < Ast
    def sexp
      code=Code.new
      stmts.each{|stmt| code << stmt.sexp}
      code
    end
  end

  class Combinatorial < Ast
    def sexp
      code=Code.new
      label_s=label ? label : "nil"
      code << "(combinatorial #{label_s}"
      code.indent=2
      code << body.sexp
      code.indent=0
      code << ")"
      code
    end
  end

  class Sequential < Ast
    def sexp
      code=Code.new
      label_s=label ? label : "nil"
      code << "(sequential #{label_s}"
      code.indent=2
      code << body.sexp
      code.indent=0
      code << ")"
      code
    end
  end

  class Assign < Ast
    def sexp
      "(assign #{lhs.sexp} #{rhs.sexp})"
    end
  end

  class If < Ast
    def sexp
      code=Code.new
      code << "(if #{cond.sexp}"
      code.indent=2
      code << "(then"
      code.indent=4
      code << self.then.sexp
      code.indent=2
      code << ")"
      if self.else
        code << "(else"
        code.indent=4
        code << self.else.sexp
        code.indent=2
        code << ")"
      end
      code.indent=0
      code << ")"
      code
    end
  end
  #===============================
  class Component < Ast
    def sexp
      "(component #{name} #{type})"
    end
  end

  class Connect < Ast
    def sexp
      "(connect #{source.sexp} #{sink.sexp})"
    end
  end

  #================================
  class Binary < Expression
    def sexp
      "(#{op} #{lhs.sexp} #{rhs.sexp})"
    end
  end

  class Var < Term
    def sexp
      name
    end
  end

  class Const < Expression
    def sexp
      value
    end
  end
end
