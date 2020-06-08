require 'matrix'
require 'ruby2d'

class Node
  attr_accessor :x,:y,:h,:g,:f,:is_start,:not_visited,:parent,:is_end,:square
  def initialize(x,y,h,is_start,is_end,sizeX,sizeY)
    @sizeX = sizeX
    @sizeY = sizeY
    @x=x
    @y=y
    @g=1
    @h=h
    @f=1/0.0
    @parent=nil
    @is_start = is_start
    @is_end = is_end
    @not_visited = true
  end

  def visited!
    @not_visited = false
  end

  def draw
    @square = Square.new(
      x: (@x * (800/@sizeX)),
      y: (@y * (800/@sizeY)),
      size: (800/@sizeX) - 5
    )
    if @is_start
      @square.color = 'green'
    elsif @is_end
      @square.color = 'red'
    end
  end
end

class Graph
  attr_accessor :start_node,:end_node,:path,:sizeX,:sizeY
  def initialize(sizeX,sizeY,startX,startY,endX,endY)
    @sizeX = sizeX
    @sizeY = sizeY
    @nodes = Matrix.build(sizeX,sizeY) {|row , col|
      if row == startX and col == startY
        @start_node = Node.new(row,col,nil,true,false,sizeX,sizeY)
      elsif row == endX and col == endY
        @end_node = Node.new(row,col,nil,false,true,sizeX,sizeY)
      else
        Node.new(row,col,nil,false,false,sizeX,sizeY)
      end
      }

      #@nodes = @nodes.select {|node| !node.y.between?(10,12) or (node.x > 25 )}
      #@nodes = @nodes.select {|node| !node.y.between?(20,22) or (node.x < 3 )}
      #@nodes = @nodes.select {|node| !node.y.between?(24,25) or (node.x > 20 )}

      @nodes.each do |node|
        node.h = Math.sqrt((@end_node.x - node.x)**2 + (@end_node.y - node.y)**2)
      end
      @nodes = self.calculate_unvisited_nodes
  end

  def calculate_unvisited_nodes

      @unvisited = @nodes.select {|node| node.not_visited}
      @unvisited = @unvisited.sort_by {|node| node.f}
  end

  def get_node(x,y)
    @nodes.each do |node|
      if node.x == x and node.y == y
        return node
      end
    end
    false
  end

  def neighbors_of(node)
    @nodes.select { |child|
      [child.x,child.y] != [node.x,node.y] and
        child.x.between?(node.x - 1 , node.x + 1) and
        child.y.between?(node.y - 1 , node.y + 1)
     }
  end


  def calculate_path
    q = @start_node
    while q != @end_node
      #puts "#{((q.h / @start_node.h)*100).round()}%"
      unless q == @start_node
        q.square.color = 'blue'
      end
      q.visited!
      children = self.neighbors_of(q)
      children.each do |child|
        if !child.not_visited
          next
        end
        child.parent = q
        child.g = q.g + Math.sqrt((q.x - child.x)**2 + ( q.y - child.y)**2)
        child.f = child.g + child.h

      end
      self.calculate_unvisited_nodes
      q = @unvisited[0]
    end

    path = []
    node = @end_node.parent
    while node != @start_node
      node.square.color = 'purple'
      path.push(node)
      node = node.parent
    end
  end

  def draw
    @nodes.each do |node|
      node.draw
    end
  end

end

def main

  set title: "A-star"
  set width: 800
  set height: 800

  graph = Graph.new(40,40,9,4,36,37)
  graph.draw
  graph.calculate_path
  show

end

main()
