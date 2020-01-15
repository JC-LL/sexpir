require 'sxp'
require_relative 'ast'
require_relative 'log'

module Sexpir

  class Parser

    include Log

    attr_accessor :options

    def initialize
      @type_table={}
      @var_table ={}
    end

    def parse sexpfile
      log "[+] parsing  '#{sexpfile}'"
      sexp=SXP.read IO.read(sexpfile)
      ast=objectify(sexp)
    end

    def objectify sexp
      circ=Circuit.new
      sexp.shift
      circ.name=sexp.shift
      while sexp.any?
        s=sexp.shift
        case s.first
        when :signal
          circ.signals << parse_signal(s)
        when :input
          circ.inputs << parse_input(s)
        when :output
          circ.outputs << parse_output(s)
        when :assign
          circ.body << parse_assign(s)
        when :component
          circ.body << parse_component(s)
        when :connect
          circ.body << parse_connect(s)
        when :comb,:combinatorial
          circ.body << parse_comb(s)
        when :seq,:sync,:sequential
          circ.body << parse_seq(s)
        else
          raise "unknown car #{s}"
        end
      end
      circ
    end

    def expect sexp,klass,value=nil
      unless (kind=sexp.shift).is_a? klass
        log "ERROR : expecting a #{klass}. Got a #{kind}."
        raise "Syntax error"
      end
      if value
        unless value==kind
          log "ERROR : expecting value '#{value}'. Got '#{kind}'"
          raise "Syntax error"
        end
      end
      return kind
    end

    #======== IO & Signals ===========
    def parse_signal sexp
      sig=Signal.new
      sexp.shift
      sig.name=sexp.shift
      case sexp.first
      when Symbol
        sig.type=sexp.shift
      when Integer
        val=sexp.shift
        sig.type="bv#{val}"
      end
      while sexp.any?
        case sexp.first
        when Array
          ary=sexp.shift
          field_name=ary.shift
          case field_name
          when :bits_sign,:name,:reset,:reset_less,:name_override,:min,:max
            sig.send("#{field_name}=",ary.shift)
          else
            raise "unknow signal attribut '#{field_name}'"
          end
        else
          raise "unknown signal attribute '#{sexpr.first}'"
        end
      end

      sig
    end

    def parse_input sexp
      input=Input.new
      sexp.shift
      input.name=sexp.shift
      case sexp.first
      when Symbol
        input.type=sexp.shift
      when Integer
        val=sexp.shift
        input.type="bv#{val}"
      end
      while sexp.any?
        case sexp.first
        when Array
          ary=sexp.shift
          field_name=ary.shift
          case field_name
          when :bits_sign,:name,:reset,:reset_less,:name_override,:min,:max
            input.send("#{field_name}=",ary.shift)
          else
            raise "unknow signal attribut '#{field_name}'"
          end
        else
          raise "unknown signal attribute '#{sexpr.first}'"
        end
      end
      input
    end

    def parse_output sexp
      output=Output.new
      sexp.shift
      output.name=sexp.shift
      case sexp.first
      when Symbol
        output.type=sexp.shift
      when Integer
        val=sexp.shift
        output.type="bv#{val}"
      end
      while sexp.any?
        case sexp.first
        when Array
          ary=sexp.shift
          field_name=ary.shift
          case field_name
          when :bits_sign,:name,:reset,:reset_less,:name_override,:min,:max
            output.send("#{field_name}=",ary.shift)
          else
            raise "unknow signal attribut '#{field_name}'"
          end
        else
          raise "unknown signal attribute '#{sexpr.first}'"
        end
      end
      output
    end



    # ===== components stuff =====
    def parse_component sexp
      comp=Component.new
      sexp.shift
      comp.name=sexp.shift
      comp.type=sexp.shift
      comp
    end

    def parse_connect sexp
      con=Connect.new
      sexp.shift
      con.source=parse_port(sexp.shift)
      con.sink  =parse_port(sexp.shift)
      con
    end

    def parse_port sexp
      case sexp
      when Array
        port=Port.new
        sexp.shift
        port.component_name=sexp.shift
        port.name=sexp.shift
        return port
      else
        return sexp
      end
    end

    # statements
    def parse_statement sexp
      case sexp.first
      when :if
        parse_if(sexp)
      when :assign
        parse_assign(sexp)
      when :case
        parse_case(sexp)
      else
        raise "unknow statement starting with : #{sexp.first}"
      end
    end

    def parse_comb sexp
      comb=Combinatorial.new
      sexp.shift
      label=sexp.shift
      comb.body=parse_body(sexp)
      comb
    end

    def parse_seq sexp
      comb=Sequential.new
      sexp.shift
      label=sexp.shift
      comb.body=parse_body(sexp)
      comb
    end

    def parse_body sexp
      body=Body.new
      while sexp.any?
         body << parse_statement(sexp.shift)
      end
      body
    end

    def parse_if sexp
      if_=If.new
      sexp.shift
      if_.cond = parse_expression(sexp.shift)
      while sexp.any?
        case sexp.first.first
        when :then
          if_.then = parse_then(sexp.shift)
        when :elsif
          if_.elsifs << parse_elsif(sexp.shift)
        when :else
          if_.else = parse_else(sexp.shift)
        else
          raise "error parsing 'if' : #{sexp.first.first}"
        end
      end
      if_
    end

    def parse_then sexp
      sexp.shift
      body=parse_body(sexp)
      body
    end

    def parse_elsif sexp
      sexp.shift
      body=parse_body(sexp)
      body
    end

    def parse_else sexp
      sexp.shift
      body=parse_body(sexp)
      body
    end

    def parse_assign sexp
      assign=Assign.new
      sexp.shift
      assign.lhs=parse_expression(sexp.shift)
      assign.rhs=parse_expression(sexp.shift)
      assign
    end

    def parse_case sexp
      ret=Case.new
      sexp.shift
      ret.expr=parse_expression(sexp.shift)
      while sexp.any?
        ary=sexp.shift
        case ary.first
        when :when
          ret.whens << parse_when(ary)
        when :default
          ret.default=parse_default(ary)
        else
          raise "unknown case alternative : '#{ary.first}'"
        end
      end

      ret
    end

    def parse_when sexp
      ret=When.new
      sexp.shift
      ret.expr=parse_expression(sexp.shift)
      ret.body=parse_body(sexp)
      ret
    end

    def parse_default sexp
      ret=Default.new
      sexp.shift
      ret.body=parse_body(sexp)
      ret
    end

    # expressions

    def parse_expression sexp
      case sexp
      when Array
        case sexp.size
        when 1
          case sexp
          when Symbol
            return Var.new(sexp)
          when Integer
            return Const.new(sexp)
          else
            raise "unknown expression '#{sexp}'"
          end
        when 2
          ret=parse_unary(sexp)
        when 3
          ret=parse_binary(sexp)
        when 4
          ret=parse_slice(sexp)
        else
          raise "unknown expression '#{sexp}'(size = '#{sexp.size}')"
        end
      when Symbol
        ret=Var.new(sexp)
      when Integer
        ret=Const.new(sexp)
      else
        raise "unknown expression '#{sexp}'"
      end
      ret
    end

    OP_TRANSLATE={
      "gt" => ">",
      "lt" => "<",
      "eq" => "=",
      "neq"=> "/=",
      "gte"=> ">=",
      "lte"=> "<=",
    }

    NORMALIZED_OP={
      "*"  => "mul",
      "+"  => "add",
      "-"  => "sub",
      "/"  => "div",
      "="  => "eq",
      ">=" => "gte",
      "<=" => "lte",
      "/=" => "neq"
    }

    def parse_binary sexp
      case sexp.first
      when :mread
        ret=MRead.new
        sexp.shift
        ret.mem = Mem.new(sexp.shift) # memory name
        ret.addr= parse_expression(sexp.shift)
      else
        ret=Binary.new
        ret.op=sexp.shift
        #ret.op=OP_TRANSLATE[ret.op.to_s]||ret.op.to_s
        ret.op=NORMALIZED_OP[ret.op.to_s] || ret.op.to_s
        ret.lhs=parse_expression(sexp.shift)
        ret.rhs=parse_expression(sexp.shift)
      end
      ret
    end

    def parse_unary sexp
      ret=Unary.new
      ret.op=sexp.shift
      ret
    end

    def parse_slice sexp
      ret=Slice.new
      sexp.shift
      ret.expr=parse_expression(sexp.shift)
      ret.msb=parse_expression(sexp.shift)
      ret.lsb=parse_expression(sexp.shift)
      ret
    end
  end
end
