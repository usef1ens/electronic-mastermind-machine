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

    // --- Instantiation ---
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

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end

    // --- Main Test Sequence ---
    initial begin
        $dumpfile("mastermind.vcd");
        $dumpvars(0, tb_mastermind);

        $monitor("Time=%0t | Rst=%b | SW=%b | EntA=%b EntB=%b || Rnd=%d ScA=%d ScB=%d | LEDs=%b | Secret=%h",
                 $time, reset, SW, enterA, enterB, round_count_disp, scoreA_disp, scoreB_disp, led_feedback, leds_debug);

        // 1. Initialize
        reset = 1; enterA = 0; enterB = 0; SW = 0;

        // 2. Reset
        #50; reset = 0; #50; reset = 1; #50;

        // 3. Start Game (Player A Selects)
        enterA = 1; #10; enterA = 0; #20;

        // --- ROUND 1: MAKER PHASE (A enters F-A-C-E: 100-001-010-011) ---
        $display("\n--- ROUND 1: MAKER PHASE ---");
        SW = 3'b100; #10; enterA = 1; #10; enterA = 0; #20;
        SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;
        SW = 3'b010; #10; enterA = 1; #10; enterA = 0; #20;
        SW = 3'b011; #10; enterA = 1; #10; enterA = 0; #20;
        #100;  // Wait for transition

        // --- ROUND 1: BREAKER PHASE (B Guesses Correct: 100-001-010-011) ---
        $display("\n--- ROUND 1: BREAKER PHASE ---");
        #100;  // Wait for life animation (~40ns)
        SW = 3'b100; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b001; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b010; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b011; #10; enterB = 1; #10; enterB = 0; #20;

        $display("\n--- ROUND 1 COMPLETE (Expect ScB=1, Rnd=1) ---");
        #200;  // Wait for score/round update + transition

        // --- ROUND 2: MAKER PHASE (B enters 7-7-7-7: 111 x4) ---
        $display("\n=== ROUND 2 START: Roles Swapped (Expect Rnd=1) ===");
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        SW = 3'b111; #10; enterB = 1; #10; enterB = 0; #20;
        #100;  // Wait for transition

        // --- ROUND 2: BREAKER PHASE (A Does Not Guess Correct: 3 Wrong Guesses to Deplete Lives) ---
        $display("\n--- ROUND 2: BREAKER PHASE (A Wrong Guesses: A-A-A-A x3 = Lose Round) ---");
        #100;  // Wait for life animation

        // Wrong Guess 1: All 001 (valid, no match) → lives=2, retry
        // NOTE: Repeat this block 3x to deplete lives (3→2→1→0) → A_lostRound → ScB+=1 (to 2), round_done → Rnd=2? Wait, no: after lost, back to ST_MAKER? But spec covers up to this.
        repeat(3) begin  // 3 wrong guesses to lose round (lives start at 3)
            SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  // Letter 1
            SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  // 2
            SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  // 3
            SW = 3'b001; #10; enterA = 1; #10; enterA = 0; #20;  // 4 → LEDproc_A → lives-- → if 0: lostRound

            #150;  // Wait for LEDproc (mismatch LEDs=00000000) + lifeA delay (40ns) + retry setup
        end

        $display("\n--- ROUND 2 COMPLETE (Expect ScB=2, Rnd=1, EnterA ignored if B tries, but not tested here) ---");
        #300;  // Wait for final lostRound delay + round_done pulse + transition to ST_FINISH? (if scores>1)

        $display("\n--- SIMULATION END: Covers Start, Maker A, Breaker B Correct, Maker B, Breaker A Wrong (Lost) ---");
        $finish;
    end

endmodule
