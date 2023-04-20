/////////////////////////////////////////////////////////
////////    module : Layer2         		     ////////
////////    Editor : Cheng Yu Lin         		 ////////
////////    Last edit : 2021/8/16 14:18          //////// 
////////    Intro : Flatten                      ////////
/////////////////////////////////////////////////////////

//`timescale 1ns/10ps

module Layer2(clk, reset, Finish1, 
    crd2, cwr2, csel2, 
    caddr_rd2, cdata_rd, 
    caddr_wr2, cdata_wr2, 
    Finish2
);

input clk, reset, Finish1 ; 
input [19:0] cdata_rd ;

output Finish2, crd2, cwr2 ;
output reg [2:0] csel2 ;

output reg [11:0] caddr_wr2, caddr_rd2 ;
output reg [19:0] cdata_wr2 ;

reg [2:0] cs, ns ;


// Finite State Machine
always @(posedge clk or posedge reset) begin
    if(reset)
        cs <= 0 ;

    else 
        cs <= ns ;
end

always @(*) begin
    case (cs)
        3'd0 : ns <= {2'b0, Finish1} ;
        3'd1 : ns <= 3'd2 ;
        3'd2 : ns <= 3'd3 ;
        3'd3 : ns <= 3'd4 ;
        3'd4 : ns <= {&caddr_wr2[10:0], 2'b01} ; 
        default : ns <= 0 ;
    endcase
end 

// Output decoder
assign crd2 = (cs==1) | (cs==3) ;
assign cwr2 = (cs==2) | (cs==4) ;
assign caddr_wr2_en = (cs==2) | (cs==4) ;
assign Finish2 = (cs==5) ;

always @(*) begin
    case (cs)
        3'd1 : csel2 <= 3 ;
        3'd2 : csel2 <= 5 ;
        3'd3 : csel2 <= 4 ;
        3'd4 : csel2 <= 5 ;
        default : csel2 <= 0 ;
    endcase
end

always @(posedge clk or posedge reset) begin
    if(reset)
        caddr_rd2 <= 0 ;

    else if (cs==3)
        caddr_rd2 <= caddr_rd2 + 1 ;

    else 
        caddr_rd2 <= caddr_rd2 ;
end

// data writing and reading control
always @(posedge clk or posedge reset) begin
    if(reset)
        caddr_wr2 <= 0 ;

    else if (caddr_wr2_en) 
        caddr_wr2 <= caddr_wr2 + 1 ;

    else 
        caddr_wr2 <= caddr_wr2 ;
end


always @(posedge clk or posedge reset) begin
    if(reset)
        cdata_wr2 <= 0 ;

    else 
        cdata_wr2 <= cdata_rd ;
end


endmodule