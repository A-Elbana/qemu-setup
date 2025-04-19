#!/bin/bash

# Start QEMU in the background
echo "[+] Starting QEMU..."

qemu-system-arm -M versatilepb -nographic -S -gdb tcp::1234 -kernel program &
QEMU_PID=$!

# Wait a moment to ensure QEMU is ready
sleep 1

# Run GDB with the script
echo "[+] Running GDB script..."
gdb-multiarch -batch -x dump.gdb

# Optionally kill QEMU after GDB finishes (optional, if it's still running)
echo "[+] Killing QEMU (PID $QEMU_PID)..."
kill $QEMU_PID 2>/dev/null

echo "[+] Done."
