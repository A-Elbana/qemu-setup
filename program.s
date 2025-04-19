

.global _start



.section .data
color_red:      .word 0xFF0000FF
color_green:    .word 0x00FF00FF
color_blue:     .word 0x0000FFFF
ball_pos:       .word 0x01AF00A0
lbat_pos:       .hword 0x00A0
rbat_pos:       .hword 0x00A0
.equ Width, 480
.equ Height, 320

.section .bss
.comm stack, 10000 // Reserves 10KB for the stack  

.section .text
_start:
    // Initialize stack pointer (sp) to point to the top of the stack (stack + 10000)
    LDR r13, =stack+10000 // Set sp to the top of the stack (highest address)
    MOV sp, r13
    MOV r8, #0 // Simulation Steps
reloop:
    LDR r0, =0x04000000 // Base address of the framebuffer
    MOV r1, #Width              // Set resolution width
    MOV r2, #Height              // Set resolution height
    LDR r10, =rbat_pos @ Load the address of the value in memory into R10
    LDRH r6, [r10]  @ Load the value from memory (at address R10) into R6

game_loop:
    ADD r8, #1

    BL draw 
    B game_loop 


done:
    // Exit
    MOV r7, #4 // Syscall for exit

hang:
    B hang


@ ----------------------------------------
@ Function: rbat_down
@ Purpose:  Moves the right bat down
@ Inputs:
@   No inputs. This reads/writes memory values.
rbat_down:
    PUSH {r3-r12, lr}
    LDR r10, =rbat_pos // Load the address of the right bat position
    LDRH r6, [r10] // Load the current position of the right bat
    ADDS r6, r6, #3 // Move down by 3 pixels
    CMP r6, r2      // Check max height
    BGE rbat_down_return // Return if out-of-bounds
    STRH r6, [r10] // Store the new position back to memory
rbat_down_return:
    POP {r3-r12, lr}
    BX lr



@ ----------------------------------------
@ Function: rbat_up
@ Purpose:  Moves the right bat up
@ Inputs:
@   No inputs. This reads/writes memory values.
rbat_up:
    PUSH {r3-r12, lr}
    LDR r10, =rbat_pos // Load the address of the right bat position
    LDRH r6, [r10] // Load the current position of the right bat
    SUB r6, r6, #3 // Move up by 3 pixels
    CMP r6, 0      // Check min height
    BGE rbat_up_return // Return if out-of-bounds
    STRH r6, [r10] // Store the new position back to memory
rbat_up_return:
    POP {r3-r12, lr}
    BX lr

//TODO Add lbat functions and complete ball logic

@ ----------------------------------------
@ Function: background
@ Purpose:  Draws the background of the screen
@ Inputs:
@   No inputs. This reads memory values.
background:
    PUSH {r3-r12, lr}
    MOV r3, #0                // x-coordinate for pixel 1
    MOV r4, #0                // y-coordinate for pixel 1
    LDR r5, =0x4cb2edff      // Color
draw_bg:
    BL set_pixel // Call set_pixel to draw pixel at (x, y)

    // Increment x, check if we reached the end of the row
    ADDS r3, r3, #1          // Increment x (R3)
    CMP r3, r1               // Check if x reached width (R1)
    BNE draw_bg // If x < width, continue drawing the next pixel

    // Reset x and increment y
    MOV r3, #0               // Reset x to 0
    ADDS r4, r4, #1          // Increment y (R4)
    CMP r4, r2               // Check if y reached height (R2)
    BNE draw_bg // If y < height, continue drawing the next row
    POP {r3-r12, lr}
    BX lr


@ ----------------------------------------
@ Function: draw
@ Purpose:  Draws the background, the left bat, right bat, and the ball.
@ Inputs:
@   No inputs. This reads memory values.
draw:
    PUSH {r3-r12, lr}
    // Draw left bat
    BL background
    MOV r6, #20 // X-Coordinate (Constant for bats)
    LDR r10, =lbat_pos // Y-Coordinate
    LDRH r7, [r10]
    MOV r5, #0xFFFFFFFF // Color
    MOV r10, #5 // Width
    MOV r11, #50 // Height
    BL draw_square

    // Draw right bat
    MOV r6, #460 // X-Coordinate (Constant for bats)
    LDR r10, =rbat_pos // Y-Coordinate
    LDRH r7, [r10]
    MOV r5, #0xFFFFFFFF // Color
    MOV r10, #5 // Width
    MOV r11, #50 // Height
    BL draw_square

    // Draw Ball
    LDR r10, =ball_pos // X-Coordinate
    LDRH r6, [r10, #2] // Get High (MSB) 4 bytes of r10
    LDR r10, =ball_pos // Y-Coordinate
    LDRH r7, [r10]
    MOV r5, #0xFFFFFFFF // Color
    MOV r10, #5 // Width
    MOV r11, #5 // Height
    BL draw_square
    POP {r3-r12, lr}
    BX lr

@ ----------------------------------------
@ Function: set_pixel
@ Inputs:
@   r3 = center_x
@   r4 = center_y
@   r5 = color
set_pixel:
    PUSH {r6, r14}

    // Set the pixel (x, y)

    MUL r6, r4, r1           // R6 = y * width (R4 is y, R1 is width)
    ADD r6, r6, r3           // R6 = (y * width) + x (R3 is x)
    LSL r6, r6, #2           // 4 byte offset (multiply by 4)
    ADD r6, r6, r0           // Add the base address of framebuffer
    STR r5, [r6]             // Store the pixel color in memory

    POP {r6, lr}
    BX lr

@ ----------------------------------------
@ Function: draw_square
@ Inputs:
@   r6 = center_x (cx)
@   r7 = center_y (cy)
@   r10 = width (This is essentially the dx)
@   r11 = height (This is essentially the dy)
@   r5 = color (RGBA, each two bytes)
draw_square:
    PUSH {r3-r12, lr}

    RSB r8, r10, #0 // r8 = (0-r10) = -r10 which is -dx
    SUB r8, #1 // Decrement by 1 (It misses a pixel if we don't do this)
    RSB r9, r11, #0 // r9 = (0-r11) = -r11 which is -dy
square_loop:

    ADD r8, r8, #1         // r8 = r8 + 1
    CMP r8, r10     // Compare dx with width
    BNE row_draw
    RSB r8, r10, #0
    ADD r9, #1
    CMP r9, r11
    BGE square_done
row_draw:
    ADD r3, r6, r8          @ x = cx + dx
    ADD r4, r7, r9          @ y = cy + dy
    
    // Check if the pixel is within the screen bounds
    CMP r3, #0
    BLT square_loop
    CMP r3, r1
    BGT square_loop
    CMP r4, #0
    BLT square_loop
    CMP r4, r2
    BGT square_loop

    // Draw the pixel (Now we have r3 and r4 as x and y, and r5 already has the color)
    BL set_pixel

    B square_loop

square_done:
    POP {r3-r12, lr}
    BX lr


