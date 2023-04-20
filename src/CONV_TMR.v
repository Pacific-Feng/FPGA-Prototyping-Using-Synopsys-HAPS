/////////////////////////////////////////////////////////
////////    module : CONV_TMR         		     ////////
////////    Editor : Cheng Yu Lin         		 ////////
////////    Last edit : 2021/8/31 10:52          //////// 
////////    Intro : The TMR part of Layer0       ////////
////////    (Multiply)                           ////////
/////////////////////////////////////////////////////////

//`include "Multiplier20.v"
//`timescale 1ns/10ps

module CONV_TMR(
    clk, accumulate,
    _idata, kernel, bias, 
    cdata_wr0
) ;

input clk, accumulate ;
input signed [19:0] _idata, kernel, bias ;

output signed [19:0] cdata_wr0 ;

wire signed [19:0] _cdata_wr0 ;
wire signed [39:0] __cdata_wr0, M ;
reg signed [39:0] convolution ;


assign __cdata_wr0 = convolution + {bias[19], bias[19], bias[19], bias[19], bias, 16'b0} ;
assign _cdata_wr0 = __cdata_wr0[35:16] + {19'b0, __cdata_wr0[15]} ;
assign cdata_wr0 = (_cdata_wr0[19]) ? 0 : _cdata_wr0 ;         // ReLU

Multiplier20 M0(.A(_idata), .B(kernel), .M(M)) ;

always @(posedge clk) begin                 // The convolution accumulator
	if (accumulate)
		convolution <= convolution + M ;

	else 
		convolution <= 0 ;
end


endmodule 