module code_maker(input clk, reset, codeMaker, player_A, player_B
input [11:0] R1, SW[2:0],
output reg active_p, take_code);

reg [2:0] ct1; // a counter that counts to 4 (we have numbers 0 to 7)
reg [11:0] toR1; // the register of which value will be returned
reg [1:0] state;
parameter [1:0] IDLE = 2'b00; // define the state encodings
parameter [1:0] PA = 2'b01;
parameter [1:0] PB = 2'b10;

always @ (posedge clk or posedge reset) // sequential block: state assignment
begin
    if(reset == 1'b0)
    begin
        toR1 <= 12'd0; // nullify register
        ct1 <= 3'd0; // nullify internal counter
    end
    else // in the case that we did not press the reset button
    begin 
        case(state) // cover all states
        IDLE: // at the IDLE state
        begin
            if(codeMaker) // if codemaker is 1
            begin
                if(player_A) state <= PA; // the next state is Player A in case we chose player A
                else state <= PB; // else the next state is that of player B
            end
            else state <= IDLE; // if codemaker mode is not switched on, then remain in IDLE
        end
        PA: // at player A's state
        begin
            toR1 <= {toR1[8:0], SW}; // push the 3bit input by left-shifting
            ct1 <= ct1 + 1'b1; // increment the counter
            if(ct1 == 3'd4) state <= IDLE; // if we have reached the limit then go back to IDLE
            else state <= PA; // otherwise remain in the same state
        end
        PB: // at player B's state
        begin
            toR1 <= {toR1[8:0], SW}; // push the 3bit input by left-shifting
            ct1 <= ct1 + 1'b1; // increment the counter
            if(ct1 == 3'd4) state <= IDLE; // same logic as in A's state
            else state <= PB;
        end
        default: state <= IDLE;
        // should we assigna a default value for ct1? 
        endcase


    end
end

always @ (*) // combinational block, for computing mealy outputs
begin
    case(state)
    PA:
    begin
        if(ct1 == 3'd4)
        begin
            started = 1'b1;
            active_p = 1'b0;
            take_code = 1'b0;
        end
        default: started = 1'b0, active_p = 1'b0, take_code = 1'b0;
    end
    PB:
    begin
        if(ct1 == 3'd4)
        begin
            started = 1'b1;
            active_p = 1'b1;
            take_code = 1'b0;
        end
        default: started = 1'b0, active_p = 1'b0, take_code = 1'b0;
    end
    endcase

end

endmodule