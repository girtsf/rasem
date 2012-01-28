require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe Rasem::SVGImage do
  it "should initialize an empty image" do
    img = Rasem::SVGImage.new(100, 100)
    str = img.output
    str.should =~ %r{width="100"}
    str.should =~ %r{height="100"}
  end

  it "should initialize XML correctly" do
    img = Rasem::SVGImage.new(100, 100)
    str = img.output
    str.should =~ /^<\?xml/
  end

  it "should close an image" do
    img = Rasem::SVGImage.new(100, 100)
    img.close
    str = img.output
    str.should =~ %r{</svg>}
  end

  it "should auto close an image with block" do
    img = Rasem::SVGImage.new(100, 100) do
    end
    img.should be_closed
  end
  
  it "should draw line using method" do
    img = Rasem::SVGImage.new(100, 100)
    img.line(0, 0, 100, 100)
    img.close
    str = img.output
    str.should =~ %r{<line}
    str.should =~ %r{x1="0"}
    str.should =~ %r{y1="0"}
    str.should =~ %r{x2="100"}
    str.should =~ %r{y2="100"}
  end
  
  it "should draw line using a block" do
    img = Rasem::SVGImage.new(100, 100) do
      line(0, 0, 100, 100)
    end
    str = img.output
    str.should =~ %r{<line}
    str.should =~ %r{x1="0"}
    str.should =~ %r{y1="0"}
    str.should =~ %r{x2="100"}
    str.should =~ %r{y2="100"}
  end

  it "should draw a line with style" do
    img = Rasem::SVGImage.new(100, 100) do
      line(0, 0, 10, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a circle" do
    img = Rasem::SVGImage.new(100, 100) do
      circle(0, 0, 10)
    end
    str = img.output
    str.should =~ %r{<circle}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{r="10"}
  end

  it "should draw a circle with style" do
    img = Rasem::SVGImage.new(100, 100) do
      circle(0, 0, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end
  
  it "should draw an arc" do
    img = Rasem::SVGImage.new(100, 100) do
      arc( 10, 10, 5, 0, 135)
    end
    str = img.output
    str.should =~ %r{<path.*a.*?>}
  end
  
  it "should draw an arc with style" do
    img = Rasem::SVGImage.new(100, 100) do
      arc( 10, 10, 5, 0, 135, {:stroke => "green"})
    end
    str = img.output
    str.should =~ %r{<path.*a.*?stroke.*?green.*?>}
  end  
  
  it "should draw a rectangle" do
    img = Rasem::SVGImage.new(100, 100) do
      rectangle(0, 0, 100, 300)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
  end

  it "should draw a rectangle with style" do
    img = Rasem::SVGImage.new(100, 100) do
      rectangle(0, 0, 10, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a symmetric round-rectangle" do
    img = Rasem::SVGImage.new(100, 100) do
      rectangle(0, 0, 100, 300, 20)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
    str.should =~ %r{rx="20"}
    str.should =~ %r{ry="20"}
  end

  it "should draw a symmetric rounded-rectangle with style" do
    img = Rasem::SVGImage.new(100, 100) do
      rectangle(0, 0, 10, 10, 2, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a non-symmetric round-rectangle" do
    img = Rasem::SVGImage.new(100, 100) do
      rectangle(0, 0, 100, 300, 20, 5)
    end
    str = img.output
    str.should =~ %r{<rect}
    str.should =~ %r{width="100"}
    str.should =~ %r{height="300"}
    str.should =~ %r{rx="20"}
    str.should =~ %r{ry="5"}
  end

  it "should draw a non-symmetric rounded-rectangle with style" do
    img = Rasem::SVGImage.new(100, 100) do
      rectangle(0, 0, 10, 10, 2, 4, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end
  
  it "should draw an ellipse" do
    img = Rasem::SVGImage.new(100, 100) do
      ellipse(0, 0, 100, 300)
    end
    str = img.output
    str.should =~ %r{<ellipse}
    str.should =~ %r{cx="0"}
    str.should =~ %r{cy="0"}
    str.should =~ %r{rx="100"}
    str.should =~ %r{ry="300"}
  end

  it "should draw an ellipse with style" do
    img = Rasem::SVGImage.new(100, 100) do
      ellipse(0, 0, 3, 10, :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a polygon given an array of points" do
    img = Rasem::SVGImage.new(100, 100) do
      polygon([[0,0], [1,2], [3,4]])
    end
    str = img.output
    str.should =~ %r{<polygon}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should draw a polygon with style" do
    img = Rasem::SVGImage.new(100, 100) do
      polygon([[0,0], [1,2], [3,4]], :fill=>"white")
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{fill:white}
  end

  it "should draw a polyline given an array of points" do
    img = Rasem::SVGImage.new(100, 100) do
      polyline([[0,0], [1,2], [3,4]])
    end
    str = img.output
    str.should =~ %r{<polyline}
    str.should =~ %r{points="0,0 1,2 3,4"}
  end

  it "should fix style names" do
    img = Rasem::SVGImage.new(100, 100) do
      circle(0, 0, 10, :stroke_width=>3)
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
  end
  
  it "should group styles" do
    img = Rasem::SVGImage.new(100, 100) do
      with_style :stroke_width=>3 do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
  end

  it "should group styles nesting" do
    img = Rasem::SVGImage.new(100, 100) do
      with_style :stroke_width=>3 do
        with_style :fill=>"black" do
          circle(0, 0, 10)
        end
      end
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:3}
    str.should =~ %r{fill:black}
  end

  it "should group styles override nesting" do
    img = Rasem::SVGImage.new(100, 100) do
      with_style :stroke_width=>3 do
        with_style :stroke_width=>5 do
          circle(0, 0, 10)
        end
      end
    end
    str = img.output
    str.should =~ %r{style=}
    str.should =~ %r{stroke-width:5}
  end

  it "should group styles limited effect" do
    img = Rasem::SVGImage.new(100, 100) do
      with_style :stroke_width=>3 do
        with_style :stroke_width=>5 do
        end
      end
      circle(0, 0, 10)
    end
    str = img.output
    str.should_not =~ %r{stroke-width:3}
    str.should_not =~ %r{stroke-width:5}
  end
  
  it "should explicit styles should override default styles" do
     img = Rasem::SVGImage.new(100, 100) do
         with_style :stroke=>"green" do
             circle( 0, 0, 10)
         end
     end
     str = img.output
     str.should_not =~ %r{stroke:black}
     str.should =~ %r{stroke:green}
  end
  
  it "should create a group" do
    img = Rasem::SVGImage.new(100, 100) do
      group :stroke_width=>3 do
        circle(0, 0, 10)
        circle(20, 20, 10)
      end
    end
    str = img.output
    str.should =~ %r{<g .*circle.*circle.*</g>}m
  end
  
  it "should translate group" do
    img = Rasem::SVGImage.new(100, 100) do
      group( {:stroke_width=>3}, [25, 30] ) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{<g .*translate.*?25,.*?30.*</g>}m
  end
  
  it "should rotate group" do
    img = Rasem::SVGImage.new(100, 100) do
      group( {:stroke_width=>3}, nil, 45 ) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{<g.*rotate.*?45.*</g>}m
  end
  
  it "should scale group uniformly when given a single value" do
    img = Rasem::SVGImage.new(100, 100) do
      group( {:stroke_width=>3}, nil, nil, 25 ) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{<g.*scale.*?25.*</g>}m      
  end
  
  it "should scale group by x & y when given an array" do
    img = Rasem::SVGImage.new(100, 100) do
      group( {:stroke_width=>3}, nil, nil, [25, 10] ) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should =~ %r{<g.*scale.*?25, 10.*</g>}m      
  end  
  
  it "should only contain one transform tag per group" do
    img = Rasem::SVGImage.new(100, 100) do
      group( {:stroke_width=>3}, [20, 20], 45 ) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should_not =~ %r{<g.*transform.*?transform.*?>}
  end

  it "should not apply transforms when not specified" do
    img = Rasem::SVGImage.new(100, 100) do
      group( {:stroke_width=>3}) do
        circle(0, 0, 10)
      end
    end
    str = img.output
    str.should_not =~ %r{<g .*transform.*</g>}m      
  end
  
  it "should allow Image creation without block" do
    img = Rasem::SVGImage.new(100, 100)
    str = img.output
    str.should =~ %r{width="100"}
    str.should =~ %r{height="100"}     
  end
  
  it "should allow style to be specified without block" do
    img = Rasem::SVGImage.new(100, 100) do
        set_style( {:stroke => "green"})
        circle( 0, 0, 10)
        unset_style
        line( 0, 0, 10, 10)
    end
    str = img.output
    str.should =~ %r{circle.*?stroke.*?green}
    str.should_not =~ %r{line.*?green}
  end
  
  it "should allow group to be specified without block" do
    img = Rasem::SVGImage.new(100, 100) do
        start_group( {:stroke =>"green"} )
            circle( 0, 0, 10)
        end_group
    end
    str = img.output
    str.should =~ %r{<g .*circle.*</g>}m   
  end
  
  it "should update width and height after init" do
    img = Rasem::SVGImage.new(100, 100) do
      set_width 200
      set_height 300
    end
    str = img.output
    str.should =~ %r{width="200"}
    str.should =~ %r{height="300"}
  end

  it "should draw text" do
    img = Rasem::SVGImage.new(100, 100) do
      text 10, 20, "Hello world!"
    end
    str = img.output
    str.should =~ %r{<text}
    str.should =~ %r{x="10"}
    str.should =~ %r{y="20"}
    str.should =~ %r{Hello world!}
  end

  it "should draw multiline text" do
    img = Rasem::SVGImage.new(100, 100) do
      text 10, 20, "Hello\nworld!"
    end
    str = img.output
    str.should =~ %r{<text.*tspan.*tspan.*</text}
  end
  
  it "should draw text with font" do
    img = Rasem::SVGImage.new(100, 100) do
      text 10, 20, "Hello\nworld!", :font_family=>"Times", "font-size"=>24
    end
    str = img.output
    str.should =~ %r{font-family="Times"}
    str.should =~ %r{font-size="24"}
  end

  it "should generate an image out of a .rasem file" do
    rasem_file = Tempfile.new("temp.rasem")
    rasem_file.puts "circle 50, 50, 50"
    rasem_file.close
    
    File.should_not be_exists(rasem_file.path+".svg")
    Rasem::Application.run!(rasem_file.path)
    
    File.should be_exists(rasem_file.path+".svg")
  end
  
  it "should raise an exception for a malformed .rasem file" do
    rasem_file = Tempfile.new("temp.rasem")
    rasem_file.puts "@x.asdf"
    rasem_file.close
    
    lambda { Rasem::Application.run!(rasem_file.path) }.should raise_error
  end
  
  it "should generate only the portion of backtrace in .rasem file" do
    rasem_file = Tempfile.new("temp.rasem")
    rasem_file.puts "@x.asdf"
    rasem_file.close
    
    begin
      Rasem::Application.run!(rasem_file.path)
    rescue Exception => e
      e.backtrace.should have(1).lines
    end
  end
end
