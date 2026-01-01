module mastermind(
    input clk,
    input reset,
    
    input enterA,
    input enterB,
    input [2:0] SW,         
    
    // Outputs
    output [1:0] round_count_disp,
    output [1:0] scoreA_disp, scoreB_disp,
    output [11:0] leds_debug,
    output [7:0] led_feedback 
);

    // --- Configuration Constant ---
    // IMPORTANT: 
    // Set to 4 for Simulation (Fast blinking).
    // Set to 25000000 for FPGA Board (0.25s blinking).
    localparam BLINK_CYCLES = 4; 

    // --- Internal Signals ---
    wire start_active_p, start_take_code, start_started, start_clearRegs;
    wire maker_active_p, maker_take_code, maker_started;
    wire [11:0] secret_code; 
    wire [11:0] breaker_guess;
    wire [1:0] updated_ptA, updated_ptB, updated_rounds;
    wire breaker_LED_Proc, breaker_codeMaker; 
    wire breaker_pickA, breaker_pickB;
    wire round_restart;
    wire [1:0] current_round;

    reg playerA_is_maker; 
    reg [2:0] main_state; 
    parameter ST_START = 0, ST_MAKER = 1, ST_BREAKER = 2, ST_FINISH = 3;

    // --- Submodules ---

    start_state START_UNIT (
        .clk(clk), .reset(reset), .enterA(enterA), .enterB(enterB),
        .active_p(start_active_p), .take_code(start_take_code),
        .started(start_started), .clearRegs(start_clearRegs)
    );

    code_maker MAKER_UNIT (
        .clk(clk), .reset(reset), 
        .codeMaker(main_state == ST_MAKER), 
        .player_A(playerA_is_maker),        
        .player_B(!playerA_is_maker),
        .enterA(enterA), .enterB(enterB),
        .SW(SW),
        .active_p(maker_active_p), .take_code(maker_take_code), 
        .started(maker_started),
        .toR1(secret_code)
    );

    code_breaker BREAKER_UNIT (
        .clk(clk), .reset(reset), 
        .codeBreaker(main_state == ST_BREAKER), 
        .player_A(!playerA_is_maker),           
        .player_B(playerA_is_maker),
        .SW(SW),
        .codemaker_code(secret_code),
        .enterA(enterA), .enterB(enterB),
        .init_ptA(updated_ptA), .init_ptB(updated_ptB),
        .round_counter(current_round),
        .codebreaker_code(breaker_guess),
        .pointsOfA(updated_ptA), .pointsOfB(updated_ptB),
        .updated_round_counter(updated_rounds),
        .LED_Proc(breaker_LED_Proc), 
        .codeMaker(breaker_codeMaker), 
        .pickPlayerA(breaker_pickA), .pickPlayerB(breaker_pickB)
    );

    round_counter ROUND_UNIT (
        .clk(clk), .reset(reset), 
        .round_done(breaker_codeMaker), 
        .CountA(updated_ptA), .CountB(updated_ptB),
        .Round(current_round),
        .restartgame(round_restart)
    );

    // --- LED Logic ---
    wire is_game_over;
    assign is_game_over = (main_state == ST_FINISH);

    // We use the localparam defined at the top of this module
    led_comparator #(.BLINK_SPEED(BLINK_CYCLES)) U_LED_FEEDBACK (
        .clk(clk),
        .reset(reset),
        .guess_val(breaker_guess),
        .secret_val(secret_code),
        .game_over(is_game_over),
        .leds(led_feedback)
    );

    // --- Main FSM ---
    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            main_state <= ST_START;
            playerA_is_maker <= 1; 
        end else begin
            case(main_state)
                ST_START: begin
                    if(start_started) main_state <= ST_MAKER;
                end
                ST_MAKER: begin
                    if(maker_started) main_state <= ST_BREAKER;
                end
                ST_BREAKER: begin
                    if (round_restart) begin
                        main_state <= ST_FINISH;
                    end
                    else if(updated_rounds != current_round) begin
                        playerA_is_maker <= ~playerA_is_maker; 
                        main_state <= ST_MAKER; 
                    end
                end
                ST_FINISH: begin
                    // Game Over state
                end
            endcase
        end
    end

    // Simulation Assignments
    assign round_count_disp = current_round;
    assign scoreA_disp = updated_ptA;
    assign scoreB_disp = updated_ptB;
    assign leds_debug = secret_code;
    
endmodule