from PIL import Image
import numpy as np

# Define screen dimensions (480*320) and color format (RGB565)
width, height = 480,320
fb_size = width * height

# Open the raw framebuffer dump
with open("fb.raw", "rb") as f:
    raw = f.read()



# Convert raw data to RGB565 pixels
pixels = []
for i in range(0, len(raw), 4):
    pixel = int.from_bytes(raw[i:i+4], 'little')
    r = (pixel >> 8*3)
    g = (pixel >> 8*2) & 0xFF
    b = (pixel >> 8) & 0xFF

    pixels.append((r, g, b))
# Create and display the image
img = Image.new("RGB", (width, height))
img.putdata(pixels)
img.show()
