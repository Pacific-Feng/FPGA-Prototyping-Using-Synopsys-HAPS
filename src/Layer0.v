/////////////////////////////////////////////////////////
////////    module : Layer0         		     ////////
////////    Editor : Cheng Yu Lin         		 ////////
////////    Last edit : 2021/9/1 14:10           //////// 
////////    Intro : Include zero padding,        ////////
////////    convolution and rectified linear     ////////
////////    unit                                 ////////
/////////////////////////////////////////////////////////

//`include "CONV_TMR.v"
//`include "Voter20.v"
/`timescale 1ns/10ps

module Layer0(
	reset, clk, ready, busy, 
	idata, 
	cwr0,  ZCR_complete, Finish0,
	iaddr,
	cdata_wr0, caddr_wr0
) ;  

input reset, clk, ready, busy ; 
input signed [19:0] idata ; 
 
output cwr0, Finish0 ; 
output reg ZCR_complete ;
output reg signed [11:0] caddr_wr0 ;
output signed [11:0] iaddr ; 
output signed [19:0] cdata_wr0 ; 	    // pixel data after zero padding and convolution

wire en_9sdc ;
wire [1:0] error ;
wire signed [19:0] kernel, _idata, bias ; 
wire signed [19:0] cdata_wrA, cdata_wrB, cdata_wrC ;

reg signed [7:0] X_coord, Y_coord  ;	    // coordinate transform register   
reg signed [7:0] X_add, Y_add ;            // decide how much to add on coordinate

reg [2:0] cs, ns ;
reg [3:0] _9sdc ; 

reg signed [11:0] correction ;                     // iaddr's correction
reg signed [19:0] kernel0, kernel1 ;
reg [39:0] convolution ;
 
 
assign _ZCR_complete = !X_coord[7] & X_coord[6] & Y_coord[7] ;  

always @(posedge clk) begin
	ZCR_complete <= _ZCR_complete ;
end
 
// Finite state machine	
always @ (posedge clk or posedge reset) 
	if (reset) 
		cs <= 0 ; 
	 
	else 
		cs <= ns ; 
		 
always @ (*)  begin 
	case (cs)
		3'd0 : ns <= {1'b0, 1'b0, ready} ; 
		3'd1 : ns <= {1'b0, _9sdc[3], !(_9sdc[3] & !_ZCR_complete)} ;           
		3'd2 : ns <= 3'd1 ; 
		3'd3 : ns <= 3'd4 ;
		3'd4 : ns <= {2'b10, _9sdc[3]} ; 
		3'd5 : ns <= {1'b1, ZCR_complete, 1'b0} ; 
		default : ns <= 0 ; 
	endcase 
end 
	 
// 9-square division counter 
always @ (posedge clk)
	if (en_9sdc) 
		_9sdc <= _9sdc + 1 ; 
	 
	else
		_9sdc <= 0 ; 
    
// Output decoder 
assign cwr0 = (cs==3'd2) | (cs==3'd3) | (cs==3'd5) ; 
assign iaddr_en = (cs==3'd2) | (cs==3'd3) | (cs==3'd5) ; 
assign coord_en = (cs==3'd1) |(cs==3'd2) | (cs==3'd4) | (cs==3'd5) ;

assign en_9sdc = (cs==3'd1) | (cs==3'd4) ;
assign accumulate = (cs==3'd1) | (cs==3'd4) ;

assign Finish0 = (cs==3'd6) ;

// coordinate counter, starting from (-1, 64)
always @(*) begin
	case (_9sdc)
		4'd0 :  begin
			X_add <= 1 ; Y_add <= 0 ; 
		end
		4'd1 : begin
			X_add <= 1 ; Y_add <= 0 ;
		end
		4'd2 : begin
			X_add <= -2 ; Y_add <= -1 ;
		end 
		4'd3 : begin
			X_add <= 1 ; Y_add <= 0 ;
		end
		4'd4 : begin
			X_add <= 1 ; Y_add <= 0 ;
		end
		4'd5 : begin
			X_add <= -2 ; Y_add <= -1 ;
		end
		4'd6 : begin
			X_add <= 1 ; Y_add <= 0 ;
		end
		4'd7 : begin
			X_add <= 1 ; Y_add <= 0 ;
		end
		4'd8 : begin
			X_add <= (X_coord==64) ? -65 : -1 ; 
			Y_add <= (X_coord==64) ? ((Y_coord==-1) ? 65 : 1) : 2 ;
		end
		default: begin
			X_add <= 0 ; 
			Y_add <= 0 ;
		end
	endcase
end


always @(posedge clk or posedge reset) begin           // coordinate counter
	if(reset) begin
		X_coord <= -1 ;
		Y_coord <= 64 ;
	end

	else if(coord_en) begin
		X_coord <= X_coord + X_add ;
		Y_coord <= Y_coord + Y_add ;
	end

	else begin
		X_coord <= X_coord ;
		Y_coord <= Y_coord ;
	end

end
 
// coordinate-to-iaddress transformer
assign iaddr = caddr_wr0 + correction ;

always @(*) begin
	case (_9sdc)
		4'd0 : correction <= -65 ;
		4'd1 : correction <= -64 ;
		4'd2 : correction <= -63 ;
		4'd3 : correction <= -1 ;
		4'd4 : correction <= 0 ; 
		4'd5 : correction <= 1 ;
		4'd6 : correction <= 63 ;
		4'd7 : correction <= 64 ;
		4'd8 : correction <= 65 ;
		default: correction <= 0 ;
	endcase
end

always @(posedge clk or posedge reset) begin       // The iaddress counter
 	if (reset) begin
		caddr_wr0 <= 0 ;
 	end

	else if(iaddr_en)
		caddr_wr0 <= caddr_wr0 + 1 ;

	else 
		caddr_wr0 <= caddr_wr0 ;
end
 
// Convolution 
assign idata_sel = (X_coord[6] | X_coord[7]) | (Y_coord[6] | Y_coord[7]) ;      // coord[6] -> greater than 63, coord[7] -> less than 0
assign _idata = (idata_sel) ? 0 : idata ;         // Check zero-padding

assign kernel = (cs[2]) ? kernel1 : kernel0 ;
assign bias = (cs[2]) ? 20'hF7295 : 20'h01310 ;

always @(*) begin                            // kernel 0
	case(_9sdc)
	 	4'd0 : kernel0 <= 20'h0A89E ;
		4'd1 : kernel0 <= 20'h092D5 ;
		4'd2 : kernel0 <= 20'h06D43 ;
		4'd3 : kernel0 <= 20'h01004 ;
		4'd4 : kernel0 <= 20'hF8F71 ;
		4'd5 : kernel0 <= 20'hF6E54 ;
		4'd6 : kernel0 <= 20'hFA6D7 ;
		4'd7 : kernel0 <= 20'hFC834 ;
		4'd8 : kernel0 <= 20'hFAC19 ; 
		default : kernel0 <= 0 ;
	endcase
end

always @(*) begin                            // kernel 1
	case(_9sdc)
	 	4'd0 : kernel1 <= 20'hFDB55 ;
		4'd1 : kernel1 <= 20'h02992 ;
		4'd2 : kernel1 <= 20'hFC994 ;
		4'd3 : kernel1 <= 20'h050FD ;
		4'd4 : kernel1 <= 20'h02F20 ;
		4'd5 : kernel1 <= 20'h0202D ;
		4'd6 : kernel1 <= 20'h03BD7 ;
		4'd7 : kernel1 <= 20'hFD369 ;
		4'd8 : kernel1 <= 20'h05E68 ; 
		default : kernel1 <= 0 ;
	endcase
end

CONV_TMR T0 (
	clk, accumulate, 
    _idata, kernel, bias, 
    cdata_wrA
) ;

CONV_TMR T1 (
	clk, accumulate, 
    _idata, kernel, bias, 
    cdata_wrB
) ;

CONV_TMR T2 (
	clk, accumulate, 
    _idata, kernel, bias, 
    cdata_wrC
) ;

Voter20 V0(
	cdata_wrA, cdata_wrB, cdata_wrC, cdata_wr0,
    error
) ;


endmodule 