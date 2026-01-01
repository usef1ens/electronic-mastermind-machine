module round_counter (input clk, reset, round_done,
input [1:0] CountA, CountB,
output reg [1:0] Round,
output reg restartgame);


always @(*) begin
    restartgame = (Round == 2'd3) || (CountA > 2'd1) || (CountB > 2'd1);
end


always @(posedge clk or negedge reset) begin 
    if (reset == 0) begin
        Round <= 2'd0;
    end 
    else if (restartgame) begin
        Round <= 2'd0; // "Round <- 0"
    end 
    else if (round_done && (restartgame == 0)) begin
        Round <= Round + 2'd1; // next round
    end
end

endmodule