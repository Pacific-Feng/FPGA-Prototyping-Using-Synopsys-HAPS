//`include "MCC.v"
//`include "Layer0.v"
//`include "Layer1.v"
//`include "Layer2.v"
//`timescale 1ns/10ps

module  top(
	input		clk,
	input		reset,
	output		busy,	
	input		ready,	
			
	output	[11:0]	iaddr,
	input	[19:0]	idata,	
	
	output	 	cwr,
	output	[11:0] 	caddr_wr,
	output	[19:0] 	cdata_wr,
	
	output	 	crd,
	output	[11:0] 	caddr_rd,
	input	[19:0] 	cdata_rd,
	
	output	[2:0] 	csel
	);

wire  [11:0] caddr_wr0, caddr_wr1, caddr_wr2 ;
wire [19:0] cdata_wr0, cdata_wr1, cdata_wr2 ;
wire [2:0] csel1, csel2 ;
wire [11:0] caddr_rd1, caddr_rd2 ;


Layer0 L0 (
	reset, clk, ready, busy, 
	idata, 
	cwr0,  ZCR_complete, Finish0,
	iaddr,
	cdata_wr0, caddr_wr0
) ;  

MCC M0 (
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

Layer1 L1 (
	clk, reset, Finish0, 
	crd1, cwr1, csel1,
	caddr_rd1, cdata_rd, caddr_wr1, cdata_wr1, 
	Finish1
) ;

Layer2 L2(clk, reset, Finish1, 
    crd2, cwr2, csel2, 
    caddr_rd2, cdata_rd, 
    caddr_wr2, cdata_wr2, 
    Finish2
);


endmodule




