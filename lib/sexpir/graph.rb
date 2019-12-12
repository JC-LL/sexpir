require_relative "code"

module GRAPH

  class Graph

    attr_accessor :name,:nodes
    def initialize name
      @name=name
      @nodes=[]
    end

    def << node
      @nodes << node
    end

    def size
      @nodes.size
    end

    def include? node
      @nodes.include? node
    end

    def connect source,sink,infos={}
      raise "source nil" unless source
      raise "sink   nil" unless sink
      @nodes << source unless @nodes.include? source
      @nodes << sink   unless @nodes.include? sink
      source.to(sink,infos)
    end

    def connected? source,sink
      source.succ_edges.select{|edge| edge.sink==sink}.any?
    end

    def unconnect source,sink
      source.succ_edges.delete_if{|edge| edge.sink==sink}
      sink.pred_edges.delete_if{|edge| edge.source==source}
    end

    def delete node
      node.preds.each{|pred| unconnect(pred,node)}
      node.succs.each{|succ| unconnect(node,succ)}
      @nodes.delete(node)
    end

    def each_node &block
      @nodes.each(&block)
    end

    def each_edge &block
      edges.each(&block)
    end

    def edges
      @nodes.collect{|n| n.succ_edges}.flatten
    end

    def to_dot
      dot_code=Code.new
      dot_code << "digraph #{name} {"
      dot_code.indent=2

      each_node do |node|
        dot_code << "#{node.object_id};"
      end
      each_edge do |edge|
        label=edge.infos.to_s
        dot_code << "#{edge.object_id} -> #{edge.object_id} [label=\"#{label}\"];"
      end
      dot_code.indent=0
      dot_code << "}"
      return dot_code
    end

    def save_as dotfilename
      dot_code||=to_dot()
      dot_code.save_as dotfilename
    end
  end

  class Node
    attr_accessor :infos
    attr_accessor :succ_edges,:pred_edges

    def initialize infos={}
      @infos=infos
      @succ_edges=[]
      @pred_edges=[]
    end

    def to node,infos={}
      e=Edge.new(self,node,infos)
      @succ_edges << e
      node.pred_edges << e
    end

    def succs
      @succ_edges.collect{|edge| edge.sink}
    end

    def preds
      @pred_edges.collect{|edge| edge.source}
    end
  end

  class Edge
    attr_accessor :name,:source,:sink,:infos
    def initialize source,sink,infos={}
      @infos=infos
      @source=source
      @sink=sink
    end
  end
end
