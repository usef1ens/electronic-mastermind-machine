module code_maker(
    input clk, reset, codeMaker, player_A, player_B, enterA, enterB,
    input [2:0] SW, 
    output reg active_p, take_code, 
    output reg started, 
    output reg [11:0] toR1
);

    reg [2:0] ct1; 
    reg [1:0] state;
    
    parameter [1:0] IDLE = 2'b00; 
    parameter [1:0] PA   = 2'b01;
    parameter [1:0] PB   = 2'b10;
    parameter [1:0] DONE = 2'b11; 

    always @ (posedge clk or negedge reset) // sequential block for state transitions and signals
    begin
        if(reset == 1'b0)
        begin
            state <= IDLE; 
            toR1  <= 12'd0; 
            ct1 <= 3'd0;
        end
        else 
        begin 
            case(state) 
                IDLE: 
                begin
                    ct1 <= 3'd0; 
                    // preserving secret code
                    if(codeMaker) 
                    begin
                        if(player_A) state <= PA; 
                        else state <= PB; 
                    end
                    else state <= IDLE; 
                end

                PA: 
                begin
                    if (ct1 >= 3'd4) 
                    begin
                        state <= DONE; 
                        ct1 <= 3'd0;
                    end
                    else if(enterA) 
                    begin
                        toR1 <= {toR1[8:0], SW}; 
                        ct1 <= ct1 + 1'b1; 
                    end
                end

                PB: 
                begin
                    if (ct1 >= 3'd4) 
                    begin
                        state <= DONE; 
                        ct1   <= 3'd0;
                    end
                    else if(enterB) 
                    begin
                        toR1 <= {toR1[8:0], SW}; 
                        ct1  <= ct1 + 1'b1; 
                    end
                end
                
                DONE: 
                begin
                    // wait here until mastermind module knows by lowering codeMaker
                    if (!codeMaker) state <= IDLE; 
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    always @ (*) // combinational block for output logic
    begin
        // default values
        active_p  = 1'b0;
        take_code = 1'b0;
        started = 1'b0;

        case(state)
            PA: 
            begin
                active_p  = 1'b0;
                take_code = 1'b1; 
            end
            PB: 
            begin
                active_p  = 1'b1;
                take_code = 1'b1; 
            end
            DONE: 
            begin
                started   = 1'b1; 
            end
        endcase
    end
endmodule