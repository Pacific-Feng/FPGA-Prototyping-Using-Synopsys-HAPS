/////////////////////////////////////////////////////////
////////    module : Master Control Center       ////////
////////    Editor : Cheng Yu Lin         		 ////////
////////    Last edit : 2021/8/15 00:15          //////// 
////////    Intro : The CNN circuit's Master     ////////
////////    control center                       ////////
/////////////////////////////////////////////////////////

/`timescale 1ns/10ps

module MCC(
    clk, reset, ready,
    ZCR_complete, Finish1, Finish2,               
    busy, 
    csel, csel1, csel2, 
    cwr0, cwr1, cwr2,                     // data-writing port from Layer 
    caddr_wr0, caddr_wr1, caddr_wr2,
    cdata_wr0, cdata_wr1, cdata_wr2,
    crd1, crd2,                           // data-reading port from Layer
    caddr_rd1, caddr_rd2,
    cwr, crd,                             // data-reading and writing port for testfixture 
    caddr_wr, caddr_rd,
    cdata_wr
) ;

input clk, reset, ready ;
input ZCR_complete, Finish1, Finish2 ;              // ZCR_complete <- Layer0, switch <- Layer2 
input [2:0] csel1, csel2 ;

output reg busy ;

output cwr, crd ;
output reg [2:0] csel ;
output reg [11:0] caddr_wr, caddr_rd ;
output reg [19:0] cdata_wr ; 

input cwr0, cwr1, cwr2 ;
input [11:0] caddr_wr0, caddr_wr1, caddr_wr2 ;
input [19:0] cdata_wr0, cdata_wr1, cdata_wr2 ;
input [11:0] caddr_rd1, caddr_rd2 ;

input crd1, crd2 ;

reg [2:0] cs, ns ;


// Finite state machine 
always @(posedge clk or posedge reset) begin
    if(reset)
        cs <= 0 ;

    else 
        cs <= ns ;
end 

always @(*) begin
    case(cs)
        3'd0 : ns <= {2'b0, ready} ;
        3'd1 : ns <= {1'b0, ZCR_complete, !ZCR_complete} ;     // Layer0, kernel0
        3'd2 : ns <= {2'b01, ZCR_complete} ;                   // Layer0, kernel1
        3'd3 : ns <= {Finish1, !Finish1, !Finish1} ;           // Layer1
        3'd4 : ns <= {!Finish2, 2'b0} ;                        // Layer2
        default : ns <= 0 ;
    endcase
end 

// Output decoder 
//assign busy = !(cs==0) ;
always @(posedge clk) begin
    if (reset)
        busy <= 0 ;

    else if (ready | (cs==0))
        busy <= !busy ;

    else 
        busy <= busy ;
end

assign cwr = cwr0 | cwr1 | cwr2 ;
assign crd = crd1 | crd2 ;

always @(*) begin
    case(cs)
        3'd0 : csel <= 0 ;
        3'd1 : csel <= 3'b001 ;
        3'd2 : csel <= 3'b010 ;
        3'd3 : csel <= csel1 ;
        3'd4 : csel <= csel2 ;
        default : csel <= 0 ;
    endcase 
end

always @(*) begin
    case(csel)
        3'd1 : begin 
            caddr_wr <= caddr_wr0 ; cdata_wr <= cdata_wr0 ; caddr_rd <= caddr_rd1 ;  
        end
        3'd2 : begin
            caddr_wr <= caddr_wr0 ; cdata_wr <= cdata_wr0 ; caddr_rd <= caddr_rd1 ; 
        end 
        3'd3 : begin
            caddr_wr <= caddr_wr1 ; cdata_wr <= cdata_wr1 ; caddr_rd <= caddr_rd2 ; 
        end
        3'd4 : begin
            caddr_wr <= caddr_wr1 ; cdata_wr <= cdata_wr1 ; caddr_rd <= caddr_rd2 ; 
        end
        3'd5 : begin
            caddr_wr <= caddr_wr2 ; cdata_wr <= cdata_wr2 ; caddr_rd <= caddr_rd2 ;
        end
        default : begin
            caddr_wr <= 0 ; cdata_wr <= 0 ; caddr_rd <= 0 ; 
        end
    endcase 
end


endmodule 