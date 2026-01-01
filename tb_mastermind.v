`timescale 1ns / 1ps

module tb_mastermind();

    // inputs
    reg clk;
    reg reset;
    reg enterA;
    reg enterB;
    reg [2:0] SW;

    // outputs
    wire [1:0] round_count_disp;
    wire [1:0] scoreA_disp;
    wire [1:0] scoreB_disp;
    wire [11:0] leds_debug;
    wire [7:0] led_feedback;

    // instantiate submodules
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

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock --> 10ns period
    end

    // test
    initial begin
        $dumpfile("mastermind.vcd");
        $dumpvars(0, tb_mastermind);

        $monitor("Time=%0t | Rst=%b | SW=%b | EntA=%b EntB=%b || Rnd=%d ScA=%d ScB=%d | LEDs=%b | Secret=%h",
                 $time, reset, SW, enterA, enterB, round_count_disp, scoreA_disp, scoreB_disp, led_feedback, leds_debug);

        reset = 1; enterA = 0; enterB = 0; SW = 0; // initialize

        #50; reset = 0; #50; reset = 1; #50; // reset

        // start the game and let A be the codemaker
        enterA = 1; #10; enterA = 0; #20;

        // first round, at the maker state --> A enters F-A-C-E
        $display("\nround 1: maker state");
        SW = 3'b100; #10; enterA = 1; #10; enterA = 0; #20;
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;
        SW = 3'b010; #10; enterA = 1; #10; enterA = 0; #20;
        SW = 3'b011; #10; enterA = 1; #10; enterA = 0; #20;
        #100;  // wait for transition

        // now for the breaker state --> B guesses correctly
        $display("\nround1: breaker state");
        #100;  
        SW = 3'b100; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b001; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b010; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b011; #10; enterB = 1; #10; enterB = 0; #20;

        $display("\nround 1 completed");
        #200;  // wait for score/round update and transition

        // round 2 maker state --> B enters U-U-U-U
        $display("\nround 2 starts");
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        #100;  // wait for transition

        // round 2 breaker state --> A does not guess correct
        $display("\nround 2 breaker state");
        #100;  

        // --- Iteration 1 ---
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20; 
        #150;  

        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20; 
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20; 
        #150;

        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  
        #150;  

        $display("\nround 2 completed");
        #300; 

        $display("\nsimulation ended");
        $finish;
    end

endmodule
