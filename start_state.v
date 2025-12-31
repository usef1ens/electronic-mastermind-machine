module start_state (input clk, reset, enterA, enterB, 
output reg active_p, take_code, started, clearRegs);

reg [1:0] state;
reg [1:0] nextstate;
parameter [1:0] start = 2'd0;
parameter [1:0] PA = 2'd1;
parameter [1:0] PB = 2'd2;

always @(posedge clk or negedge reset) 
begin //Transitioning Block
        if (reset == 1'b0)
            state <= start;
        else
            state <= nextstate;
end

always @(*) 
begin // Decision block
    nextstate = state; // default value
    case(state)
    start: 
    begin
        if (enterA ^ enterB) // only if either of A and B have pressed the enter button
        begin
            if (enterA) // if it was A
            begin
                nextstate = PA;
            end
            else // if it was B
            begin
                nextstate = PB;
            end
        end
        else nextstate = start; // else remain in the start state
    end
    PA: nextstate = PA;
    PB: nextstate = PB;
        
    endcase
end

always @(*) 
begin // Computational / moore
    started = 1'b0; // default values of signals
    active_p = 1'b0;
    take_code = 1'b0;
    case(state)
    start: clearRegs = 1'b0;
    PA: 
    begin
        active_p = 1'b1;
        take_code = 1'b1;
        started = 1'b1;
    end
    PB: 
    begin
        active_p = 1'b0;
        take_code = 1'b1;
        started = 1'b1;
    end
    endcase

end


endmodule