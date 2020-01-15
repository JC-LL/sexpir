module Sexpir
  class Ast
    attr_accessor :node
    def accept(visitor, arg=nil)
       name = self.class.name.split(/::/).last
       visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end
  end

  class Circuit < Ast
    attr_accessor :name,:signals,:inputs,:outputs,:body
    def initialize
      @signals=[]
      @inputs,@outputs=[],[]
      @body=Body.new
    end
  end

  class Signal < Ast
    attr_accessor :name,:type
    attr_accessor :bits_sign
    attr_accessor :reset
    attr_accessor :reset_less
    attr_accessor :name_override
    attr_accessor :min,:max
  end

  class Io < Signal
  end

  class Port < Io
    attr_accessor :component_name,:name
  end

  class Input < Io
  end

  class Output < Io
  end

  # statements
  class Body < Ast
    attr_accessor :stmts
    def initialize
      @stmts=[]
    end

    def << e
      @stmts << e
    end
  end

  class Combinatorial < Ast
    attr_accessor :label,:body
  end

  class Sequential < Ast
    attr_accessor :label,:body
  end

  class Assign < Ast
    attr_accessor :lhs,:rhs
  end

  class If < Ast
    attr_accessor :cond,:then,:elsifs,:else
    def initialize
      @elsifs=[]
    end
  end

  class Case < Ast
    attr_accessor :expr,:whens,:default
    def initialize
      @whens=[]
    end
  end

  class When < Ast
    attr_accessor :expr,:body
  end

  class Default < Ast
    attr_accessor :body
  end
  #===============================
  class Component < Ast
    attr_accessor :name,:type
  end

  class Connect < Ast
    attr_accessor :source,:sink
  end
  #================================
  class Expression < Ast
  end

  class Binary < Expression
    attr_accessor :lhs,:op,:rhs
  end

  class Term < Expression
  end

  class Var < Term
    attr_accessor :name
    def initialize name
      @name=name
    end
  end

  class Const < Term
    attr_accessor :value
    def initialize value
      @value=value
    end
  end

  class Slice < Term
    attr_accessor :expr
    attr_accessor :msb,:lsb
  end
end
