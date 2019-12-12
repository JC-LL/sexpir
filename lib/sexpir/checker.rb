require_relative 'visitor'
require_relative 'printer'

module Sexpir

  class Checker < Visitor
    include Log
    def check circuit
      log"[+] checking circuit '#{circuit.name}'"
    end

    private
  end
end
