module reset_state(input clk, reset, btn2, 
output reg clearall, // Not sure if I had to put every register, or just send the signal to reset and directly reset in each state itself
output reg restartgame // go to state1
);

reg [1:0] state, nextstate;

parameter [1:0] IDLE = 2'd0; // Waiting to be pressed
parameter [1:0] PRESSED = 2'd1; // When button is pressed
parameter [1:0] RELEASED = 2'd2; // After button is pressed

always @(posedge clk or negedge reset) begin
    if (reset == 0)
        state <= IDLE;
    else
        state <= nextstate;
end
always @(*) begin //decision block
    nextstate = state;
    case (state)
    IDLE: begin
        if (btn2 == 0) begin // if btn2 == 1 you don't do anything
            nextstate = PRESSED;
        end
    end
    PRESSED: begin
        nextstate = RELEASED;
    end
    RELEASED: begin
        if (btn2) begin
            nextstate = IDLE;
        end
    default : nextstate = IDLE;
    end
    endcase

end
always @(*) begin
    clearall = 1'b0;
    restartgame = 1'b0;

    case(state)
        PRESSED: begin
            clearall = 1'b1;
        end
        RELEASED: begin
            if (btn2) begin
                restartgame = 1'b1;
            end
        end

    endcase
end
        
endmodule





///  not sure about that