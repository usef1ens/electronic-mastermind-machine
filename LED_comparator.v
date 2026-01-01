module led_comparator(
    input clk,
    input reset,
    input [11:0] guess_val,   // 4 letters * 3 bits = 12 bits
    input [11:0] secret_val,  // Secret code
    input game_over,          // High = Blink mode
    output reg [7:0] leds     // 8 LEDs output
    );

    // 1. Break down inputs into 3-bit letters
    wire [2:0] g3, g2, g1, g0; 
    wire [2:0] s3, s2, s1, s0; 

    assign g3 = guess_val[11:9];
    assign g2 = guess_val[8:6];
    assign g1 = guess_val[5:3];
    assign g0 = guess_val[2:0];

    assign s3 = secret_val[11:9];
    assign s2 = secret_val[8:6];
    assign s1 = secret_val[5:3];
    assign s0 = secret_val[2:0];

    // 2. Combinational Logic for Matches
    reg [7:0] match_pattern;

    always @(*) begin
        // --- Position 3 (LD7, LD6) ---
        if (g3 == s3) 
            match_pattern[7:6] = 2'b11; 
        else if (g3 == s2 || g3 == s1 || g3 == s0) 
            match_pattern[7:6] = 2'b01; 
        else 
            match_pattern[7:6] = 2'b00; 

        // --- Position 2 (LD5, LD4) ---
        if (g2 == s2) 
            match_pattern[5:4] = 2'b11;
        else if (g2 == s3 || g2 == s1 || g2 == s0) 
            match_pattern[5:4] = 2'b01;
        else 
            match_pattern[5:4] = 2'b00;

        // --- Position 1 (LD3, LD2) ---
        if (g1 == s1) 
            match_pattern[3:2] = 2'b11;
        else if (g1 == s3 || g1 == s2 || g1 == s0) 
            match_pattern[3:2] = 2'b01;
        else 
            match_pattern[3:2] = 2'b00;

        // --- Position 0 (LD1, LD0) ---
        if (g0 == s0) 
            match_pattern[1:0] = 2'b11;
        else if (g0 == s3 || g0 == s2 || g0 == s1) 
            match_pattern[1:0] = 2'b01;
        else 
            match_pattern[1:0] = 2'b00;
    end

    // 3. Blinking Timer Logic
    reg [25:0] timer;     
    reg blink_state;
    parameter BLINK_SPEED = 4; 

    always @(posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            timer <= 0;
            blink_state <= 0;
        end else if (game_over) begin
            if (timer >= BLINK_SPEED) begin
                timer <= 0;
                blink_state <= ~blink_state; // Toggle bit
            end else begin
                timer <= timer + 1;
            end
        end else begin
            blink_state <= 1; // Default ON
            timer <= 0;
        end
    end

    // 4. Output Logic (Replaced Ternary with If-Else)
    always @(*) begin
        if (game_over) begin
            if (blink_state == 1'b1) begin
                leds = 8'b11111111;
            end else begin
                leds = 8'b00000000;
            end
        end else begin
            leds = match_pattern;
        end
    end

endmodule