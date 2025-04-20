#!/bin/bash

# Start QEMU in the background
echo "[+] Starting QEMU..."

qemu-system-arm -M versatilepb -nographic -S -gdb tcp::1234 -kernel program &

# Store QEMU PID in case you want to stop it later
QEMU_PID=$!

# Wait a moment to ensure QEMU is ready
sleep 1

gdb-multiarch -batch -x dump.gdb >/dev/null &
PY_PID=$!
python video_renderer.py





# Optional: Kill QEMU when done
echo "Killing QEMU (PID=$QEMU_PID)..."
kill $QEMU_PID
kill $PY_PID

