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
      sig.type=sexp.shift
      sig
    end

    def parse_input sexp
      input=Input.new
      sexp.shift
      input.name=sexp.shift
      input.type=sexp.shift
      input
    end

    def parse_output sexp
      output=Output.new
      sexp.shift
      output.name=sexp.shift
      output.type=sexp.shift
      output
    end

    def parse_assign sexp
      assign=Assign.new
      sexp.shift
      assign.lhs=parse_expression(sexp.shift)
      assign.rhs=parse_expression(sexp.shift)
      assign
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
  end
end
