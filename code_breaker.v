// this module implements the code breaker's logic

module code_breaker(input clk, reset, codeBreaker, player_A, player_B
input [2:0] SW,
input [11:0] R1; // the codemaker's code 
input enterA, enterB,
input [1:0] init_ptA; // initial points of player A
input [1:0] init_ptB; // initial points of player B
output reg [11:0] toR2 
output reg [1:0] pointsOfA,
output reg [1:0] pointsOfB);


reg [1:0] ct2; // internal counter decrements from 3 down to 0. (to account for lives left)
reg [2:0] ct3; // internal counter that counts till 4 to take all inputs
reg [4:0] cState; // to store the code for the current state
reg [4:0] nState; // to store the code for the next state

// encode states
parameter [4:0] IDLE = 5'd0;
parameter [4:0] lifeA = 5'd1;
parameter [4:0] lifeB = 5'd2;
parameter [4:0] tryA = 5'd3;
parameter [4:0] tryB = 5'd4;
parameter [4:0] ptToA = 5'd5;
// ptToB ?
parameter [4:0] checkEachA = 5'd6;
// checkEachB ?
parameter [4:0] incrementRound = 5'd7;
// --> rest of the states go here

// always blocks
always @ (posedge clk or posedge reset) // for state transitions and reset logic (sequential)
begin
    if(reset == 1'b0) // if reset button turns on --> clear all registers and counters 
    // and go back to the IDLE state
    begin
        state <= IDLE; 
        ct2 <= 2'd0;
        ct3 <= 3'd0;
        toR2 <= 12'd0;
        pointsOfA <= init_ptA; // also initialize the counter registers returned 
        pointsOfB <= init_ptB;
    end
    else // normal flow
    begin
        state <= nState
    end
end

always @ (*) // for next state computation (combinational)
begin
    case(state) // for all cases of states
    IDLE: // if we are at the IDLE state
    begin 
        if(codeBreaker) // if we are seleting a code breaker
        begin
            // if we have selected player A
            if(player_A) nstate = lifeA; // at this state we display the lives of A left
            else nState = lifeB; // else we are guranteed to have selected player B
        end
        else nState = IDLE; // else remain in the IDLE state
    end
    lifeA: nState = tryA; // at the state where we display the lifes left for A, 
    // simply progress to the next state defined after it in the ASM chart
    lifeB: nState = tryB; // same logic as before
    tryA: // at this state we take the code of A and perform operations
    begin
        if(enterA) // only if A has entered his first character
        begin
        toR2 = {toR2[8:0], SW}; // we perform left shift and take the input of A
        ct3 = ct3 + 1'b1;
        if(ct3 == 3'd4) // if we have reached the limit
        begin
            // now that we have collected the final code, we check if they both registers are equal
            if(R1 == toR2) // if both registers are equal
            begin
                nState = ptToA; // progress to the next state
            end
            else 
            begin
                nState = checkEachA; // progress to the next state
            end
        end
        else nState = tryA; // if we did not reach the limit --> remain in the same state   
        end
        else nState = tryA; // if A did not enter his current code --> remain in the same state
    end
    tryB: 
    //copy the previous case's code and substitute A with B
    ptToA: // increment the point counter of code breaker A
    begin
        pointsOfA = pointsOfA + 1'b1; // increment the score of A
        nstate = incrementRound;
    end
    ptToB:
    //copy the previous case's code and substitute A with B
    checkEachA: // REACHED HERE

    endcase
end





endmodule