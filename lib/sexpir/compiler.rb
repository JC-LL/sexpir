require 'sxp'

require_relative 'version'
require_relative 'ast'
require_relative 'parser'
require_relative 'printer'
require_relative 'checker'
require_relative 'transformer'
require_relative 'ruby_rtl_generator'

module Sexpir

  class Compiler

    include Log
    attr_accessor :options

    def initialize
    end

    def header
      log "Sexpir compiler - version #{VERSION}"
      #log "author : jean-christophe.le_lann@ensta-bretagne.fr"
    end

    def compile sexpfile
      header
      circuit=Parser.new.parse(sexpfile)
      Printer.new.print(circuit)
      Checker.new.check(circuit)
      RubyRTLGenerator.new.generate(circuit)
    end

    def close
      log "[+] closing : log is #{$log.inspect}"
    end

  end
end
