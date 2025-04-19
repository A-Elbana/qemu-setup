# Process Documentation for creating an ARM emulator with a framebuffer. (Ubuntu 20.04)
---
- You need any version of Python 3.8+ with pygame, numpy, and PIL installed.

- Update apt repo 
```bash
sudo apt update
```

### Run this (Downloads 2.8GB)
```bash
sudo apt install qemu-system-arm gcc-arm-none-eabi gdb-multiarch
```
- **`qemu-system-arm`** is the QEMU package for ARM architectures

- **`gcc-arm-none-eabi`** is the ARM toolchain to compile and link ARM code

- **`gdb-multiarch`** is for debugging (we’ll use this to dump memory)

### The only suitable board on qemu 4.2.1 is the versatilepb. (No linker script hassle)

Run the ```./build.sh``` to build and link the arm code.

Run the ```./run.sh``` to run qemu with the -s option which holds the execution until a debugger `(gdb)` is connected, this also runs a `gdb` script which automatically connects to and drives the code execution, dumps memory at each game_loop cycle, and runs the python script `video_renderer.py` which parses the dump file and renders the screen.

## Program Flow (All of the steps below are done using the 2 shell scripts)
1) `gcc-arm-none-eabi` compiles and links the code.
2) `qemu-system-arm` takes the compiled `.elf` file and emulates a board (versatilepb) to run this code.
3) The execution on `qemu` is held until a `gdb` session (debugger) connects to it via port :1234.
4) Once a debugger session is connected `gdb` has full control of the execution. This allows us to pause and run the execution at any time. 
5) Manually or using the script, `gdb` adds a break point at the game loop's label. What this does is whenever we tell ythe execution to continue and it hits the breakpoint, the execution stops. Before we run continue again using gdb we dump the memory to the `fb.raw` file (To get the new frame after one game loop/cycle) and then proceed by running continue. (This step is done repeatedly)
6) (This step is parallel to step 5) The python script `video_renderer.py` continuously parses the `fb.raw`, translates the bytes into RGB and renders a scene.




