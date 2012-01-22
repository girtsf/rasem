class Rasem::SVGImage
  DefaultStyles = {
    :text => {:fill=>"black"},
    :line => {:stroke=>"black"},
    :rect => {:stroke=>"black"},
    :circle => {:stroke=>"black"},
    :ellipse => {:stroke=>"black"},
    :polygon => {:stroke=>"black"},
    :polyline => {:stroke=>"black"}
  }


  def initialize(width, height, output=nil, &block)
    @output = create_output(output)

    # Initialize a stack of default styles
    @default_styles = []

    write_header(width, height)
    if block
      self.instance_exec(&block)
      self.close
    end
  end

  def set_width(new_width)
    if @output.respond_to?(:sub!)
      @output.sub!(/<svg width="[^"]+"/, %Q{<svg width="#{new_width}"})
    else
      raise "Cannot change width after initialization for this output"
    end
  end

  def set_height(new_height)
    if @output.respond_to?(:sub!)
      @output.sub!(/<svg width="([^"]+)" height="[^"]+"/, %Q{<svg width="\\1" height="#{new_height}"})
    else
      raise "Cannot change width after initialization for this output"
    end
  end

  # Draw a straight line between the two end points
  def line(x1, y1, x2, y2, style=nil)
    @output << %Q{<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}"}
    write_style(style, :line)
    @output << %Q{/>\n}
  end

  # Draw a circle given a center and a radius
  def circle(cx, cy, r, style=nil)
    @output << %Q{<circle cx="#{cx}" cy="#{cy}" r="#{r}"}
    write_style(style, :circle)
    @output << %Q{/>\n}
  end

  # Draw a circular arc given center, rad & start/end locations
  def arc( cx, cy, rad, start_degrees=0, sweep_degrees=180, style=nil)
      # NOTE: These arguments differ strongly from the conceptual basis
      # of the arc as specified in SVG.  I believe these args are
      # more intuitive for most programmers.  Note that paths in general,
      # and even arcs, are far more capable than this wrapper indicates.
      # For more information, see: http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands
      def radians( degrees); 2*Math::PI * degrees / 360.0; end
      start_x = cx + rad*Math.cos( radians(start_degrees))
      start_y = cy - rad*Math.sin( radians(start_degrees))
      end_x   = cx + rad*Math.cos( radians(start_degrees + sweep_degrees)) - start_x
      end_y   = cy - rad*Math.sin( radians(start_degrees + sweep_degrees)) - start_y

      sweep = sweep_degrees < 0 ? 1 : 0
      large_arc = sweep_degrees.abs > 180 ? 1 : 0

      transform_degs = 0
      
      @output << %Q{<path d="M#{start_x},#{start_y} \
      a#{rad},#{rad} #{transform_degs} #{large_arc},#{sweep} #{end_x},#{end_y}"}
      write_style( style, :circle)
      @output << %Q{/>\n}
  end

  # Draw a rectangle or rounded rectangle
  def rectangle(x, y, width, height, *args)
    style = (!args.empty? && args.last.is_a?(Hash)) ? args.pop : nil
    if args.length == 0
      rx = ry = 0
    elsif args.length == 1
      rx = ry = args.pop
    elsif args.length == 2
      rx, ry = args
    else
      raise "Illegal number of arguments to rectangle"
    end

    @output << %Q{<rect x="#{x}" y="#{y}" width="#{width}" height="#{height}"}
    @output << %Q{ rx="#{rx}" ry="#{ry}"} if rx && ry
    write_style(style, :rectangle)
    @output << %Q{/>\n}
  end

  # Draw an circle given a center and two radii
  def ellipse(cx, cy, rx, ry, style=nil)
    @output << %Q{<ellipse cx="#{cx}" cy="#{cy}" rx="#{rx}" ry="#{ry}"}
    write_style(style, :ellipse)
    @output << %Q{/>\n}
  end

  def polygon(*args)
    polything("polygon", *args)
  end

  def polyline(*args)
    polything("polyline", *args)
  end

  # Closes the file. No more drawing is possible after this
  def close
    write_close
    @closed = true
  end

  def output
    @output.to_s
  end

  def closed?
    @closed
  end

  def with_style( style={}, &proc)
    set_style( style)
    # Call the block
    self.instance_exec(&proc)
    unset_style
  end      
  
  def set_style( style)
      # Merge passed style with current default style
     updated_style = default_style.merge( style) 
     # Push updated style to the stack
     @default_styles.push( updated_style)
  end

  def unset_style
      # Pop style again to revert changes
      @default_styles.pop
  end

  def group(style={}, translate_xy=nil, rotate=nil, &proc)
    # Open the group
    start_group( style, translate_xy, rotate)
    # Call the block
    self.instance_exec(&proc)
    # Close the group
    end_group
  end

  def start_group( style={}, translate_xy=nil, rotate=nil)
    @output << "<g "
    if translate_xy
        x, y = translate_xy
        @output << "transform=\"translate( #{x}, #{y})\" "
    end
    if rotate
        @output << "transform=\"rotate( #{rotate})\" "
    end
    write_style(style)
    @output << ">\n"      
  end
  
  def end_group
    @output << "</g>\n"      
  end
  
  def text(x, y, text, style=nil)
    @output << %Q{<text x="#{x}" y="#{y}"}
    style = DefaultStyles[:text] unless style
    style = fix_style( default_style.merge(style))
    @output << %Q{ font-family="#{style.delete "font-family"}"} if style["font-family"]
    @output << %Q{ font-size="#{style.delete "font-size"}"} if style["font-size"]
    write_style( style, :text)
    @output << ">"
    dy = 0      # First line should not be shifted
    text.each_line do |line|
      @output << %Q{<tspan x="#{x}" dy="#{dy}em">}
      dy = 1    # Next lines should be shifted
      @output << line.rstrip
      @output << "</tspan>"
    end
    @output << "</text>"
  end

private
  # Creates an object for ouput out of an argument
  def create_output(arg)
    if arg.nil?
      ""
    elsif arg.respond_to?(:<<)
      arg
    else
      raise "Illegal output object: #{arg.inspect}"
    end
  end

  # Writes file header
  def write_header(width, height)
    @output << <<-HEADER
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{width}" height="#{height}" version="1.1"
  xmlns="http://www.w3.org/2000/svg">
    HEADER
  end

  # Write the closing tag of the file
  def write_close
    @output << "</svg>"
  end

  # Draws either a polygon or polyline according to the first parameter
  def polything(name, *args)
    return if args.empty?
    style = (args.last.is_a?(Hash)) ? args.pop : nil
    coords = args.flatten
    raise "Illegal number of coordinates (should be even)" if coords.length.odd?
    @output << %Q{<#{name} points="}
    until coords.empty? do
      x = coords.shift
      y = coords.shift
      @output << "#{x},#{y}"
      @output << " " unless coords.empty?
    end
    @output << '"'
    write_style(style, name.to_sym)
    @output << '/>'
  end

  # Return current deafult style
  def default_style
    @default_styles.last || {}
  end

  # Returns a new hash for styles after fixing names to match SVG standard
  def fix_style(style)
    new_style = {}
    style.each_pair do |k, v|
      new_k = k.to_s.gsub('_', '-')
      new_style[new_k] = v
    end
    new_style
  end

  # Writes styles to current output
  # Avaialable styles are:
  # fill: Fill color
  # stroke-width: stroke width
  # stroke: stroke color
  # fill-opacity: fill opacity. ranges from 0 to 1
  # stroke-opacity: stroke opacity. ranges from 0 to 1
  # opacity: Opacity for the whole element
  def write_style(style, caller=nil)
    if not style
      style = DefaultStyles.fetch( caller, {}).merge( default_style)
    end
    style_ = fix_style(default_style.merge(style))
    return if style_.empty?
    @output << ' style="'
    style_.each_pair do |attribute, value|
      @output << "#{attribute}:#{value};"
    end
    @output << '"'
  end
end


