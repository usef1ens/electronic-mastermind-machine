// this module implements the code breaker's logic
module code_breaker(input clk, reset, codeBreaker, player_A, player_B,
    input [2:0] SW,
    input [11:0] codemaker_code, // the codemaker's code
    input enterA, enterB,
    input [1:0] init_ptA, // initial points of player A
    input [1:0] init_ptB, // initial points of player B
    input [1:0] round_counter, // the current round we are at
    output reg [11:0] codebreaker_code, // the code inputed by the code breaker is an output for other modules to see
    output reg [1:0] pointsOfA, // to update the points of A
    output reg [1:0] pointsOfB, //
    output reg LED_Proc, // to tell another module to initiate the LED glowing process
    output reg codeMaker, // for the active player module
    output reg pickPlayerA, // for the active player module
    output reg pickPlayerB, // for the active player module
    output reg [1:0] updated_round_counter);

    reg [2:0] lives_counter; // internal counter decrements from 3 down to 0. (to account for lives left)
    reg [2:0] letters_inputed; // internal counter that counts till 4 to take all inputs
    reg [3:0] cState; // to store the code for the current state
    reg [3:0] nState; // to store the code for the next state
    reg [2:0] delay_timer; // to count the waiting time

    // encode states, they're 11
    parameter [3:0] IDLE = 4'd0;
    // 5 states in case A is the codebreaker
    parameter [3:0] lifeA = 4'd1; // to display the lives left
    parameter [3:0] tryA = 4'd2; // to take the input from codebreaker
    parameter [3:0] ptToA = 4'd3; // to give the codebreaker a point
    parameter [3:0] LEDproc_A = 4'd4; // to show differences between both codes
    parameter [3:0] A_lostRound = 4'd5; // to give the codemaker a point
    // 5 states in case B is the codebreaker
    parameter [3:0] lifeB = 4'd6; // to display the lives left
    parameter [3:0] tryB = 4'd7; // to take the input from codebreaker
    parameter [3:0] ptToB = 4'd8; // to give the codebreaker a point
    parameter [3:0] LEDproc_B = 4'd9; // to show differences between both codes
    parameter [3:0] B_lostRound = 4'd10; // to give the codemaker a point

    // always blocks
    always @ (posedge clk or negedge reset) // for state transitions and reset logic (sequential)
    begin
        if(reset == 1'b0) // if reset button turns on --> clear all registers and counters, and reset
                         // and go back to the IDLE state
        begin
            cState <= IDLE; // go back to the next state
            delay_timer <= 3'd0; // nullify the timer
        end
        else // normal flow
        begin
            cState <= nState; // transition to the next state
            // timer Logic
            if(cState == lifeA || cState == lifeB || cState == ptToA || cState == ptToB || cState == A_lostRound || cState == B_lostRound)
                delay_timer <= delay_timer + 1;
            else
                delay_timer <= 0;
        end
    end

    always @ (*) // for next state computation (combinational)
    begin
        case(cState) // for all cases of states
            IDLE: // if we are at the IDLE state
            begin
                if(codeBreaker) // if we are seleting a code breaker
                begin
                    // if we have selected player A
                    if(player_A)
                        nState = lifeA; // at this state we display the lives of A left
                    else
                        nState = lifeB; // else we are guranteed to have selected player B
                end
                else
                    nState = IDLE; // else remain in the IDLE state
            end

            lifeA:
            begin
                if(delay_timer >= 3)
                    nState = tryA; // transition to the next state only after waiting for the appropriate time
                else
                    nState = lifeA; // i.e. waiting for 4 cycles
            end

            tryA: // at this state we take the code of A and perform operations
            begin
                if(letters_inputed == 3'd4) // if we have reached the limit
                begin
                    // now that we have collected the final code, we check if they both registers are equal
                    if(codemaker_code == codebreaker_code)
                        nState = ptToA; // if both registers are equal, go to the state where you give points to A
                    else
                        nState = LEDproc_A; // else, go to the state where you show the differences between both codes
                end
                else
                    nState = tryA; // if we did not reach the limit --> remain in the same state
            end

            LEDproc_A: // after showing the differences,
            begin
                if(lives_counter == 0)
                    nState = A_lostRound;// if we do not have lives left
                else
                    nState = lifeA;
            end

            ptToA:
            begin
                if(delay_timer >= 3)
                    nState = IDLE;
                else
                    nState = ptToA; // return to the IDLE state only after 4 cycles
            end

            A_lostRound:
            begin
                if(delay_timer >= 3)
                    nState = IDLE; // same logic as before
                else
                    nState = A_lostRound;
            end

            lifeB:
            begin
                if(delay_timer >= 3)
                    nState = tryB; // transition to the next state only after waiting for the appropriate time
                else
                    nState = lifeB; // i.e. waiting for 4 cycles
            end

            tryB: // at this state we take the code of B and perform operations
            begin
                if(letters_inputed == 3'd4) // if we have reached the limit
                begin
                    // now that we have collected the final code, we check if they both registers are equal
                    if(codemaker_code == codebreaker_code)
                        nState = ptToB; // if both registers are equal, go to the state where you give points to B
                    else
                        nState = LEDproc_B; // else, go to the state where you show the differences between both codes
                end
                else
                    nState = tryB; // if we did not reach the limit --> remain in the same state
            end

            LEDproc_B: // after showing the differences,
            begin
                if(lives_counter == 0)
                    nState = B_lostRound;// if we do not have lives left
                else
                    nState = lifeB;
            end

            ptToB:
            begin
                if(delay_timer >= 3)
                    nState = IDLE;
                else
                    nState = ptToB; // return to the IDLE state only after 4 cycles
            end

            B_lostRound:
            begin
                if(delay_timer >= 3)
                    nState = IDLE;
                else
                    nState = B_lostRound;
            end

            default:
                nState = IDLE; // by default we are at the IDLE state
        endcase
    end

    always @ (posedge clk or negedge reset) // for register/counter operations (sequential)
    begin
        if (reset == 1'b0) // if reset button was activated
        begin
            lives_counter <= 2'd0; // clear internal counters
            letters_inputed <= 3'd0; //
            codebreaker_code <= 12'd0; // clear the register
            updated_round_counter <= 2'd0; // set the returned round counter to 0 --> WHY??
            pointsOfA <= 2'd0; // force score to 0 upon reset
            pointsOfB <= 2'd0; // force score to 0 upon reset
        end
        else // normal case
        begin
            case(cState)
                IDLE:
                begin
                    lives_counter <= 2'd3; // initiate the internal counters
                    letters_inputed <= 3'd0; //
                    codebreaker_code <= 12'd0; // clear the register
                    pointsOfA <= init_ptA; // also initialize the counter registers returned
                    pointsOfB <= init_ptB;
                    updated_round_counter <= round_counter; // set the returned round counter to the current number of rounds
                end

                lifeA:
                begin
                    // NOTE: Reset letters_inputed counter when starting/retrying a guess
                    letters_inputed <= 3'd0;
                    // NOTE: Clear previous guess when starting new attempt
                    codebreaker_code <= 12'd0;
                end

                lifeB:
                begin
                    // NOTE: Reset letters_inputed counter when starting/retrying a guess
                    letters_inputed <= 3'd0;
                    // NOTE: Clear previous guess when starting new attempt
                    codebreaker_code <= 12'd0;
                end

                tryA:
                begin
                    if(enterA && SW != 3'b000) // '-' is not accepted, and enter button must be pushed
                    begin
                        codebreaker_code <= {codebreaker_code[8:0], SW}; // enter the 3bit input and left shift the register
                        letters_inputed <= letters_inputed + 1'b1; // increment the letter counter
                    end
                    // do I need an else statement here?
                end

                ptToA:
                begin
                    if(delay_timer == 0) // only update once
                    begin
                        pointsOfA <= pointsOfA + 1'b1; // A wins a point for guessing the code correctly
                        updated_round_counter <= updated_round_counter + 1'b1; // we have finalized 1 round
                    end
                end

                LEDproc_A:
                begin
                    lives_counter <= lives_counter - 1'b1; // decrement lives counter
                end

                A_lostRound:
                begin
                    if(delay_timer == 0) // only update once
                    begin
                        pointsOfB <= pointsOfB + 1'b1; // increment the count of the other player
                        updated_round_counter <= updated_round_counter + 1'b1; // we have finalized 1 round
                    end
                end

                tryB:
                begin
                    if(enterB && SW != 3'b000) // only if enterB is pressed
                    begin
                        codebreaker_code <= {codebreaker_code[8:0], SW}; // enter the 3bit input and left shift the register
                        letters_inputed <= letters_inputed + 1'b1; // increment the letter counter
                    end
                    // do I need an else statement here?
                end

                ptToB:
                begin
                    if(delay_timer == 0)
                    begin
                        pointsOfB <= pointsOfB + 1'b1; // A wins a point for guessing the code correctly
                        updated_round_counter <= updated_round_counter + 1'b1; // we have finalized 1 round
                    end
                end

                LEDproc_B:
                begin
                    lives_counter <= lives_counter - 1'b1; // decrement lives counter
                end

                B_lostRound:
                begin
                    if(delay_timer == 0)
                    begin
                        pointsOfA <= pointsOfA + 1'b1; // increment the count of the other player
                        updated_round_counter <= updated_round_counter + 1'b1; // we have finalized 1 round
                    end
                end

                default:
                    cState <= IDLE; // if we do not know where we are, then by default we are at the IDLE state
            endcase
        end
    end

    always @ (*) // for mealy/moore outputs
    begin
        // default values
        codeMaker = 1'b0;
        pickPlayerA = 1'b0;
        LED_Proc = 1'b0;
        pickPlayerB = 1'b0;

        case(cState)
            ptToA:
            begin
                LED_Proc = 1'b1;
                // NOTE: Only pulse codeMaker for 1 cycle!
                // Otherwise round_counter increments 4 times (0->1->2->3->0).
                if (delay_timer == 3'd0)
                begin
                    codeMaker = 1'b1;
                    pickPlayerA = 1'b1;
                end
            end

            LEDproc_A:
            begin
                LED_Proc = 1'b1;
            end

            A_lostRound:
            begin
                // NOTE: Gated with timer
                if (delay_timer == 3'd0)
                begin
                    codeMaker = 1'b1;
                    pickPlayerA = 1'b1;
                end
            end

            ptToB:
            begin
                LED_Proc = 1'b1;
                // NOTE: Gated with timer
                if (delay_timer == 3'd0)
                begin
                    codeMaker = 1'b1;
                    pickPlayerB = 1'b1;
                end
            end

            LEDproc_B:
            begin
                LED_Proc = 1'b1;
            end

            B_lostRound:
            begin
                // NOTE: Gated with timer
                if (delay_timer == 3'd0)
                begin
                    codeMaker = 1'b1;
                    pickPlayerB = 1'b1;
                end
            end
        endcase
    end

endmodule
