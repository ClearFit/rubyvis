module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Arc
    def self.Arc
      Rubyvis::Layout::Arc
    end
    
    # @class Implements a layout for arc diagrams. An arc diagram is a network
    # visualization with a one-dimensional layout of nodes, using circular arcs to
    # render links between nodes. For undirected networks, arcs are rendering on a
    # single side; this makes arc diagrams useful as annotations to other
    # two-dimensional network layouts, such as rollup, matrix or table layouts. For
    # directed networks, links in opposite directions can be rendered on opposite
    # sides using <tt>directed(true)</tt>.
    #
    # <p>Arc layouts are particularly sensitive to node ordering; for best results,
    # order the nodes such that related nodes are close to each other. A poor
    # (e.g., random) order may result in large arcs with crossovers that impede
    # visual processing. A future improvement to this layout may include automatic
    # reordering using, e.g., spectral graph layout or simulated annealing.
    #
    # <p>This visualization technique is related to that developed by
    # M. Wattenberg, <a
    # href="http://www.research.ibm.com/visual/papers/arc-diagrams.pdf">"Arc
    # Diagrams: Visualizing Structure in Strings"</a> in <i>IEEE InfoVis</i>, 2002.
    # However, this implementation is limited to simple node-link networks, as
    # opposed to structures with hierarchical self-similarity (such as strings).
    #
    # <p>As with other network layouts, three mark prototypes are provided:<ul>
    #
    # <li><tt>node</tt> - for rendering nodes; typically a {@link pv.Dot}.
    # <li><tt>link</tt> - for rendering links; typically a {@link pv.Line}.
    # <li><tt>label</tt> - for rendering node labels; typically a {@link pv.Label}.
    #
    # </ul>For more details on how this layout is structured and can be customized,
    # see {@link pv.Layout.Network}.
    
    class Arc < Network
      @properties=Network.properties.dup      
      attr_accessor :_interpolate, :_directed, :_reverse
      def initialize
        super
        @_interpolate=nil # cached interpolate
        @_directed=nil # cached directed
        @_reverse=nil # cached reverse
        @_sort=nil
        that=self
        @link.data(lambda {|_p|
            s=_p.source_node;t=_p.target_node
            that._reverse != (that._directed or (s.breadth < t.breadth)) ? [s, t] : [t, s]
        }).interpolate(lambda{ that._interpolate})
      end
      
      def build_implied(s)
        return true if network_build_implied(s)
        # Cached
        
        nodes = s.nodes
        orient = s.orient
        sort = @_sort
        index = Rubyvis.range(nodes.size)
        w = s.width
        h = s.height
        r = [w,h].min / 2.0 
        # /* Sort the nodes. */
        if (sort)
          index.sort! {|a,b| sort.call(a,b)}
        end
        
        
        
        #/** @private Returns the mid-angle, given the breadth. */
        mid_angle=lambda do |b| 
          case orient 
            when "top"
              -Math::PI / 2.0
            when "bottom"
              Math::PI / 2.0
            when "left"
              Math::PI
            when "right"
              0
            when "radial"
              (b - 0.25) * 2.0 * Math::PI
          end
        end
        
        # /** @private Returns the x-position, given the breadth. */
        x= lambda do |b|
        case orient 
          when "top"
            b * w
          when "bottom"
           b * w
          when "left"
          0;
          when "right"
          w;
          when "radial"
            w / 2.0 + r * Math.cos(mid_angle.call(b))
          end
        end
        
        # /** @private Returns the y-position, given the breadth. */
        y=lambda do |b| 
          case orient 
          when "top"
            0;
          when "bottom"
            h;
          when "left"
            b* h
          when "right"
            b * h
          when "radial"
            h / 2.0 + r * Math.sin(mid_angle.call(b))
          end
        end
        
        #/* Populate the x, y and mid-angle attributes. */
        nodes.each_with_index do |nod, i|
          n=nodes[index[i]]
          n.breadth=(i+0.5) / nodes.size
          b=n.breadt
          n.x=x[b]
          n.y=y[b]
          n.mid_angle=min_angle[b]
        end        
        
        @_directed = s.directed
        @_interpolate = s.orient == "radial" ? "linear" : "polar"
        @_reverse = s.orient == "right" or s.orient == "top"
        
      end
      
      attr_accessor_dsl :orient, :directed
      
      def self.defaults
        Arc.new.mark_extend(Network.defaults).
          orient("bottom")
      end
      
      # Specifies an optional sort function. The sort function follows the same
      # comparator contract required by {@link pv.Dom.Node#sort}. Specifying a sort
      # function provides an alternative to sort the nodes as they are specified by
      # the <tt>nodes</tt> property; the main advantage of doing this is that the
      # comparator function can access implicit fields populated by the network
      # layout, such as the <tt>linkDegree</tt>.
      #
      # <p>Note that arc diagrams are particularly sensitive to order. This is
      # referred to as the seriation problem, and many different techniques exist to
      # find good node orders that emphasize clusters, such as spectral layout and
      # simulated annealing.
      #
      # @param {function} f comparator function for nodes.
      # @returns {pv.Layout.Arc} this.
      def sort(f)
        @_sort=f
        self
      end
      
      
      
    end
  end
end

