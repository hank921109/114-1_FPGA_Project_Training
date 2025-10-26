`timescale 1ns / 1ps

module HW1_TwoCounter(
    input clk,
    input rst,
    input [7:0] in_upperBound1,
    input [7:0] in_upperBound2,
    output out_state
    );
    
    reg [7:0] cnt1, cnt2;
    reg state;
    
    assign out_state = state; 
        
    //FSM
    always@(negedge rst or posedge clk)
    begin
        if(rst == 0) 
            state <= 0;
        else
         case (state)
            1'b0 : //counter1 is counting
                if (cnt1 >= in_upperBound1)
                    state <= 1;                
            1'b1 ://counter2 is counting
                if (cnt2 >= in_upperBound2)
                    state <= 0;                
            default : state <= 0;
         endcase

    end //counter1

    //counter1
     always@(negedge rst or posedge clk)
    begin
        if(rst == 0) 
            cnt1 <= 0;
        else
         case (state)
            1'b0 : //counter1 is counting
                cnt1 <= cnt1 + 1;
                //cnt2 <= 0;             
            1'b1 ://counter2 is counting
                cnt1 <= 0;
            default : state <= 0;
         endcase
    end //counter1
    
    //counter2
    always@(negedge rst or posedge clk)
    begin
        if(rst == 0) 
            cnt2 <= 0;
        else
         case (state)
            1'b0 : //counter1 is counting
                cnt2 <= 0;
                //cnt2 <= 0;             
            1'b1 ://counter2 is counting
                cnt2 <= cnt2 + 1;
            default : state <= 0;
         endcase
    end //counter1
endmodule
