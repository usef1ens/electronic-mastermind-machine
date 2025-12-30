
module code_maker(input clk, reset, codeMaker, player_A, player_B, enterA, enterB,
input SW[2:0],
output reg active_p, take_code, started
output reg [11:0] toR1);

reg [2:0] ct1; // a counter that counts to 4 (we have numbers 0 to 7)
reg [1:0] state;
parameter [1:0] IDLE = 2'b00; // define the state encodings
parameter [1:0] PA = 2'b01;
parameter [1:0] PB = 2'b10;

always @ (posedge clk or posedge reset) // sequential block: state assignment
begin
    if(reset == 1'b0)
    begin
        state <= IDLE; // go to the initial state
        toR1 <= 12'd0; // nullify register
        ct1 <= 3'd0; // nullify internal counter
    end
    else // in the case that we did not press the reset button
    begin 
        case(state) // cover all states
        IDLE: // at the IDLE state
        begin
            ct1 <= 3'd0; // nullify counter
            if(codeMaker) // if codemaker is 1
            begin
                if(player_A) state <= PA; // the next state is Player A in case we chose player A
                else state <= PB; // else the next state is that of player B
            end
            else state <= IDLE; // if codemaker mode is not switched on, then remain in IDLE
        end
        PA: // at player A's state
        begin
            if(enterA) // only if the codemaker enters these digits
            begin
                toR1 <= {toR1[8:0], SW}; // push the 3bit input by left-shifting
                ct1 <= ct1 + 1'b1; // increment the counter 
                if(ct1 == 3'd3) state <= IDLE; // same logic as in A's state 
                // NOTE: (justify why are you checking the counter being at 3 and not 4)
                else state <= PA; 
            end
            else state <= PA; // if enter was not pressed, check it at the next clk pulse
        end
        PB: // at player B's state
        begin
            if(enterB) // only if the codemaker enters these digits
            begin
                toR1 <= {toR1[8:0], SW}; // push the 3bit input by left-shifting
                ct1 <= ct1 + 1'b1; // increment the counter 
                if(ct1 == 3'd3) state <= IDLE; // same logic as in A's state
                else state <= PB; 
            end
            else state <= PB; // if enter was not pressed, check it at the next clk pulse
        end
        default: state <= IDLE;
        // should we assigna a default value for ct1? 
        endcase


    end
end

always @ (*) 
begin
    case(state)
        PA: 
        begin
            if (ct1 == 3'd4) 
            begin
                started   = 1'b1;
                active_p  = 1'b0;
                take_code = 1'b0;
            end
            else 
            begin
                started   = 1'b0;
                active_p  = 1'b0;
                take_code = 1'b0;
            end
        end

        PB: 
        begin
            if (ct1 == 3'd4) 
            begin
                started   = 1'b1;
                active_p  = 1'b1;
                take_code = 1'b0;
            end
            else 
            begin
                started   = 1'b0;
                active_p  = 1'b1;
                take_code = 1'b0;
            end
        end

        default: 
        begin // Covers IDLE state
            started   = 1'b0;
            active_p  = 1'b0;
            take_code = 1'b0;
        end
    endcase
end

endmodule