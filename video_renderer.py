import pygame
from PIL import Image
import numpy as np
import time

# Initialize Pygame
pygame.init()

# Define screen dimensions (480*320) and color format (RGB565)
width, height = 480, 320
fb_size = width * height

# Set up the Pygame display window
screen = pygame.display.set_mode((width, height))

# Open the raw framebuffer dump
with open("fb.raw", "rb") as f:
    while True:

        f.seek(0)
        # Read the next framebuffer chunk
        raw = f.read(fb_size * 4)
        
        
        # Convert raw data to RGB565 pixels
        pixels = []
        for i in range(0, len(raw), 4):
            pixel = int.from_bytes(raw[i:i+4], 'little')
            r = (pixel >> 8*3)
            g = (pixel >> 8*2) & 0xFF
            b = (pixel >> 8) & 0xFF
            pixels.append((r, g, b))

        # Create a Pygame surface and display it
        img = Image.new("RGB", (width, height))
        img.putdata(pixels)
        
        # Convert the image to a Pygame surface
        pygame_surface = pygame.image.fromstring(np.array(img).tobytes(), (width, height), "RGB")
        
        # Display the surface on the Pygame window
        screen.blit(pygame_surface, (0, 0))
        pygame.display.update()
        
        # Delay to simulate video frame rate (30 FPS)
        time.sleep(1/120)
        
        # Handle events (like window close)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
