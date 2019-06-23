require "stumpy_png"

module Mandelbrot
  VERSION = "0.1.0"

  extend self

  record Complex, x : Float64, y : Float64

  def escapes?(p)
    p.x*p.x + p.y*p.y > 4.0
  end

  def next_iter(p, p0)
    Complex.new(x: p.x * p.x - p.y * p.y + p0.x, y: 2.0 * p.x * p.y + p0.y)
  end

  def iterations(p, limit)
    p0 = p
    limit.times do |i|
      return i if escapes?(p)
      p = next_iter(p, p0)
    end
    limit
  end

  def iter_area(w, h, center, mag, &block)
    cx, cy = center.x, center.y
    p = 4.0 / Math.min(w, h) / mag
    x0 = cx - w/2.0*p
    y0 = cy + h/2.0*p
    i = 0
    h.times do |y|
      w.times do |x|
        yield i, x, y, Complex.new(x: x0 + x*p, y: y0 - y*p)
        i += 1
      end
    end
  end

  record RGBA, r : UInt8, g : UInt8, b : UInt8, a : UInt8

  PALETTE = [
    RGBA.new(66, 30, 15, 255),
    RGBA.new(25, 7, 26, 255),
    RGBA.new(9, 1, 47, 255),
    RGBA.new(4, 4, 73, 255),
    RGBA.new(0, 7, 100, 255),
    RGBA.new(12, 44, 138, 255),
    RGBA.new(24, 82, 177, 255),
    RGBA.new(57, 125, 209, 255),
    RGBA.new(134, 181, 229, 255),
    RGBA.new(211, 236, 248, 255),
    RGBA.new(241, 233, 191, 255),
    RGBA.new(248, 201, 95, 255),
    RGBA.new(255, 170, 0, 255),
    RGBA.new(204, 128, 0, 255),
    RGBA.new(153, 87, 0, 255),
    RGBA.new(106, 52, 3, 255),
  ]

  BLACK = RGBA.new(0, 0, 0, 255)

  def pixel_color(v, limit)
    if v > 0 && v < limit
      return PALETTE[v % 16]
    end
    BLACK
  end

  # draw_pix draws a Mandelbrot set in and returns an RGBA buffer.
  def draw_pix(width, height, cx, cy, mag, limit)
    img = Array(UInt8).new(width * height * 4, 0)
    iter_area(width, height, Complex.new(x: cx, y: cy), mag) do |i, x, y, p|
      v = iterations(p, limit)
      pixel = pixel_color(v, limit)
      offset = (i * 4)
      img[offset + 0] = pixel.r
      img[offset + 1] = pixel.g
      img[offset + 2] = pixel.b
      img[offset + 3] = pixel.a
    end
    img
  end

  def draw_png(width, height, cx, cy, mag, limit)
    canvas = StumpyPNG::Canvas.new(width, height)
    iter_area(width, height, Complex.new(x: cx, y: cy), mag) do |i, x, y, p|
      v = iterations(p, limit)
      pixel = pixel_color(v, limit)
      canvas[x, y] = StumpyPNG::RGBA.from_rgb_n(pixel.r, pixel.g, pixel.b, 8)
    end
    canvas
  end
end
