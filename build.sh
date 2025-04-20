#!/bin/bash

# Assemble and link ARM assembly
arm-none-eabi-as -o program.o program.s && arm-none-eabi-ld -T linker.ld -o program program.o

echo "Build complete!"
