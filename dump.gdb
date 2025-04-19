file program
# Disable pagination
set pagination off

# Connect to the QEMU instance
target remote :1234

# Set a breakpoint at the start of the game loop
break game_loop

# Start execution
continue

# Periodically dump memory (every time execution reaches the breakpoint)
while 1
    # Dump the framebuffer memory
    dump binary memory fb.raw $r0 $r0+480*320*4

    # Continue execution after dumping memory
    continue
end
