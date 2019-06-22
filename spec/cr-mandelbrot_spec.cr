require "./spec_helper"

include Mandelbrot

describe Mandelbrot do
  describe "iterations" do
    p1 = Complex.new(x: 0.9, y: 0.9)
    p2 = Complex.new(x: 0.4, y: 0.4)
    p3 = Complex.new(x: 0.1, y: 0.01)

    it "should calculate the correct number of iterations" do
      iterations(p1, 10).should eq 1
      iterations(p2, 10).should eq 8
      iterations(p3, 10).should eq 10
    end
  end

  describe "color" do
    it "should return the correct color" do
      pixel_color(0, 10).should eq RGBA.new(0, 0, 0, 255)
      pixel_color(10, 10).should eq RGBA.new(0, 0, 0, 255)
      pixel_color(4, 10).should eq RGBA.new(0, 7, 100, 255)
    end
  end

  describe "iter_area" do
    w = 6
    h = 4
    c = Complex.new(0.0, 0.0)
    mag = 1.0

    it "should iterate the product of w and h times" do
      count = 0
      iter_area(w, h, c, mag) do |i, x, y, _point|
        count += 1
      end
      count.should eq w*h
    end

    context "range" do
      describe "iter_area" do
        w = 6
        h = 4
        c = Complex.new(0.0, 0.0)
        mag = 1.0
        min_x = 0.0
        min_y = 0.0
        max_x = 0.0
        max_y = 0.0
        it "should produce the expected minimum and maximum values" do
          img = Array(Complex).new(w * h)
          iter_area(w, h, c, mag) do |i, _x, _y, point|
            img << point
            x, y = point.x, point.y
            if x < min_x
              min_x = x
            end
            if x > max_x
              max_x = x
            end
            if y < min_y
              min_y = y
            end
            if y > max_y
              max_y = y
            end
          end
          img[0].should eq Complex.new(x: -3.0, y: 2.0)
          img[(w*h - 1)].should eq Complex.new(x: 2.0, y: -1.0)
          min_x.should eq -3.0
          max_x.should eq 2.0
          min_y.should eq -1.0
          max_y.should eq 2.0
        end
      end
    end
  end

  describe "draw_pix" do
    w = 6
    h = 4
    c = Complex.new(x: 0.0, y: 0.0)
    mag = 1.0
    limit = 1000

    it "should populate the buffer with the expected values" do
      img = draw_pix(w, h, c.x, c.y, mag, limit)
      img[3*4 + 0].should eq 25
      img[3*4 + 1].should eq 7
      img[3*4 + 2].should eq 26
      img[3*4 + 3].should eq 255
    end
  end

  describe "draw_png" do
    w = 800
    h = 800
    c = Complex.new(x: 0.0, y: 0.0)
    mag = 1.0
    limit = 1000

    it "should draw a png" do
      canvas = draw_png(w, h, c.x, c.y, mag, limit)
      StumpyPNG.write(canvas, "mandelbrot_test.png")
    end
  end
end
