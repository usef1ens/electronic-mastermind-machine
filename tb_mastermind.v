`timescale 1ns / 1ps

module tb_mastermind();

    // Inputs
    reg clk;
    reg reset;     
    reg enterA;
    reg enterB;
    reg [2:0] SW;  

    // Outputs
    wire [1:0] round_count_disp;
    wire [1:0] scoreA_disp;
    wire [1:0] scoreB_disp;
    wire [11:0] leds_debug;
    wire [7:0] led_feedback; 

    // --- Standard Instantiation ---
    mastermind uut (
        .clk(clk), 
        .reset(reset), 
        .enterA(enterA), 
        .enterB(enterB), 
        .SW(SW), 
        .round_count_disp(round_count_disp), 
        .scoreA_disp(scoreA_disp), 
        .scoreB_disp(scoreB_disp), 
        .leds_debug(leds_debug), 
        .led_feedback(led_feedback)
    );

    // --- Clock Generation (Finite Loop) ---
    initial begin
        $dumpfile("mastermind.vcd");  // Name of the output waveform file
        $dumpvars(0, tb_mastermind);  // Record all signals in this module and submodules
        clk = 0;
        // 2000 cycles is enough to play one full round
        repeat (2000) begin
            #5 clk = ~clk;
        end
    end

    // --- Main Test Sequence ---
    initial begin
        // 1. Initialize
        reset = 1; 
        enterA = 0;
        enterB = 0;
        SW = 0;

        // 2. Reset (Active Low)
        #50;
        reset = 0; 
        #50;
        reset = 1; 
        #50;

        // 3. Start Game
        enterA = 1; #20; enterA = 0; #20;

        // --- MAKER PHASE (Secret: F-A-C-E) ---
        // F (100)
        SW = 3'b100; #10; enterA = 1; #20; enterA = 0; #20;
        // A (001)
        SW = 3'b001; #10; enterA = 1; #20; enterA = 0; #20;
        // C (010)
        SW = 3'b010; #10; enterA = 1; #20; enterA = 0; #20;
        // E (011)
        SW = 3'b011; #10; enterA = 1; #20; enterA = 0; #20;

        #50; 

        // --- BREAKER PHASE (Guess: F-A-C-E) ---
        // F (100)
        SW = 3'b100; #10; enterB = 1; #20; enterB = 0; #20;
        // A (001)
        SW = 3'b001; #10; enterB = 1; #20; enterB = 0; #20;
        // C (010)
        SW = 3'b010; #10; enterB = 1; #20; enterB = 0; #20;
        // E (011)
        SW = 3'b011; #10; enterB = 1; #20; enterB = 0; #20;

        // --- OBSERVE BLINKING ---
        // LEDs should toggle ON/OFF roughly every 40ns (4 cycles)
        #200; 
        
        $stop;
    end

endmodule