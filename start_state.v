module start_state (input clk, reset, enterA, enterB, 
output reg active_p, take_code, started);

reg [1:0] state;
reg [1:0] nextstate;
parameter [1:0] start = 2'd0;
parameter [1:0] PA = 2'd1;
parameter [1:0] PB = 2'd2;

always @(posedge clk or posedge reset) begin //Transitioning Block
        if (reset)
            state <= start;
        else
            state <= nextstate;
end

always @(*) begin // Decision block
    nextstate = state;
    case(state)
    start: begin
        if (enterA ^ enterB) begin
            if (enterA) begin
                nextstate = PA;
            end
            else begin
                nextstate = PB;
            end
        end
        else nextstate = start;
    end
    PA: nextstate = PA;
    PB: nextstate = PB;
        
    endcase
end

always @(*) begin // Computational / moore
    started = 1'b0;
    active_p = 1'b0;
    take_code = 1'b0;
    case(state)
    default:  begin
        started = 1'b0;
        active_p = 1'b0;
        take_code = 1'b0;
    end

    start: begin

    end
    PA: begin
        active_p = 1'b1;
        take_code = 1'b1;
        started = 1'b1;
    end
    PB: begin
        active_p = 1'b0;
        take_code = 1'b1;
        started = 1'b1;
    end
    endcase

end


endmodule