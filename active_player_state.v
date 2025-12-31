module active_player_state(input clk, reset, active_p, take_code, started
output player_A, player_B, code_maker, code_breaker);

reg state;
parameter IDLE = 1'b0;
reg nextstate;

always @(posedge clk or posedge reset) begin
    if (reset == 1'b0) begin
        state <= IDLE;
    end
    else begin
        state <= nextstate;
    end
end

always @(*) begin
    nextstate = IDLE;
end

always @(*) begin 
    player_A = 1'b0; // defaults
    player_B = 1'b0;
    code_maker = 1'b0;
    code_breaker = 1'b0;
    case (state)
        IDLE: begin
            if (started) begin //Diamond 1: Started? 

                if (active_p) begin //Diamond 2: Active_P?

                    if (take_code) begin //Diamond 3: Take_code?

                        code_maker = 1'b1; // Player_A Code_maker
                        player_A = 1'b1;
                    end 
                    else begin
                        code_breaker = 1'b1; // Player_A Code_breaker
                        player_A = 1'b1;
                    end
                end
                else begin
                    if (take_code) begin // Diamond 3: take_code?
                        code_maker = 1'b1;     // Player_B Code_maker
                        player_B = 1'b1;
                    end 
                    else begin
                        code_breaker = 1'b1;   // Player_B code_breaker
                        player_B = 1'b1;
                    end
                end
            end // If started = 0 all outputs would be 0 still
        end
    endcase
end
endmodule