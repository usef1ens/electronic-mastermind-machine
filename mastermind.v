module mastermind(
    input clk,
    input reset,
    
    input enterA,
    input enterB,
    input [2:0] SW,         
    
    // outputs
    output [1:0] round_count_disp, 
    output [1:0] scoreA_disp, scoreB_disp, 
    output [11:0] leds_debug, 
    output [7:0] led_feedback 
);

    // internal signals
    wire start_active_p, start_take_code, start_started, start_clearRegs; 
    wire maker_active_p, maker_take_code, maker_started;
    wire [11:0] secret_code; 
    wire [11:0] breaker_guess; 
    wire [1:0] updated_ptA, updated_ptB, updated_rounds; 
    wire breaker_LED_Proc, breaker_codeMaker; 
    wire breaker_pickA, breaker_pickB; 
    wire round_restart;
    wire [1:0] current_round;

    // register
    reg playerA_is_maker; 
    reg [2:0] main_state; 
    reg [2:0] next_state;
    
    // registers for active player logic
    reg next_maker;

    // state encodings
    parameter ST_START = 3'd0, ST_MAKER = 3'd1, ST_BREAKER = 3'd2, ST_FINISH = 3'd3;

    // submodules

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
        .clk(clk), .reset(reset && !start_clearRegs), 
        .round_done(breaker_codeMaker), 
        .CountA(updated_ptA), .CountB(updated_ptB),
        .Round(current_round),
        .restartgame(round_restart)
    );

    wire is_game_over;
    assign is_game_over = (main_state == ST_FINISH);

    led_comparator U_LED_FEEDBACK (
        .clk(clk),
        .reset(reset),
        .guess_val(breaker_guess), 
        .secret_val(secret_code), 
        .game_over(is_game_over),
        .leds(led_feedback)
    );
    
    
    // Main ASM (to implement the active player and the reset module logic in the ASM charts)
    always @(posedge clk or negedge reset) // sequential block for next state assignment and reset logic
    begin
        if(reset == 1'b0) 
        begin
            main_state <= ST_START; 
            playerA_is_maker <= 1'b1; // default reset value
        end 
        else 
        begin
            main_state <= next_state;
            playerA_is_maker <= next_maker;
        end
    end

    always @(*) // combinational block for next state computation
    begin
        next_state = main_state; // default to stay in current state

        case(main_state)
            ST_START: 
            begin
                if(start_started) next_state = ST_MAKER;
            end
            ST_MAKER: 
            begin
                if(maker_started) next_state = ST_BREAKER;
            end
            ST_BREAKER: 
            begin
                if (round_restart) 
                begin
                    next_state = ST_FINISH;
                end
                else if(updated_rounds != current_round) 
                begin
                    next_state = ST_MAKER; 
                end
            end
            ST_FINISH: 
            begin
                next_state = ST_FINISH;
            end
            default: next_state = ST_START;
        endcase
    end

    // combinational block that implements the active player logic
    always @(*) 
    begin
        // default
        next_maker = playerA_is_maker; 
       
        case(main_state)
            ST_START: 
            begin
                if (start_started) 
                begin
                     if (start_active_p == 1'b0) next_maker = 1'b1; // player A is codemaker
                     else next_maker = 1'b0; // player B is codemaker
                end
            end

            ST_BREAKER: 
            begin
                // now swap roles
                if (updated_rounds != current_round && !round_restart) 
                begin
                    next_maker = ~playerA_is_maker; 
                end
            end
        endcase
    end

    // for simulation assignment
    assign round_count_disp = current_round;
    assign scoreA_disp = updated_ptA;
    assign scoreB_disp = updated_ptB;
    assign leds_debug = secret_code;
    
endmodule