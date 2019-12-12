require_relative 'ast_sexp'

module Sexpir
  class Printer
    def print circuit
      puts "[+] pretty printing"
      puts circuit.sexp
    end
  end
end
