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

  class Body < Ast
    attr_accessor :stmts
    def initialize
      @stmts=[]
    end

    def << e
      @stmts << e
    end
  end

  class Assign < Ast
    attr_accessor :lhs,:rhs
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
end
