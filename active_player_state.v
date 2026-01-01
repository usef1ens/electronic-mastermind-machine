module active_player_state(input clk, reset, active_p, take_code, started
output player_A, player_B, code_maker, code_breaker);

reg state; // to assign the single state in the corresponding ASM Chart
parameter IDLE = 1'b0; // to encode the IDLE state
reg nextstate;

always @(posedge clk or posedge reset) // sequential block for state transition and reset logic
begin
    if (reset == 1'b0) state <= IDLE;
    else state <= nextstate;
end

always @(*) // combinational block for next state computation
begin
    nextstate = IDLE; // next state is always the IDLE state
end

always @(*) // combinational block for mealy outputs
begin 
    player_A = 1'b0; // default values
    player_B = 1'b0;
    code_maker = 1'b0;
    code_breaker = 1'b0;
    case (state)
        IDLE:  // if we are in the IDLE state
        begin
            if (started) //Diamond 1: Started?
            begin  
                if (active_p) //Diamond 2: Active_P?
                begin 
                    if (take_code) //Diamond 3: Take_code?
                    begin 
                        code_maker = 1'b1; // Player_A Code_maker
                        player_A = 1'b1;
                    end 
                    else 
                    begin
                        code_breaker = 1'b1; // Player_A Code_breaker
                        player_A = 1'b1;
                    end
                end
                else 
                begin
                    if (take_code) // Diamond 3: take_code?
                    begin 
                        code_maker = 1'b1;     // Player_B Code_maker
                        player_B = 1'b1;
                    end 
                    else 
                    begin
                        code_breaker = 1'b1;   // Player_B code_breaker
                        player_B = 1'b1;
                    end
                end
            end // If started = 0 all outputs would be 0 still
        end
    endcase
end
endmodule