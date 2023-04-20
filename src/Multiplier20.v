/////////////////////////////////////////////////////////
////////    module : Multiplier20         		 ////////
////////    Editor : Cheng Yu Lin         		 ////////
////////    Last edit : 2021/8/14 15:32          //////// 
////////    Intro : It's a 20 bits * 20 bits     ////////
////////    Multiplier                           ////////
/////////////////////////////////////////////////////////

//`timescale 1ns/10ps

module Multiplier20(A, B, M) ; 
 
input signed [19:0] A, B ;
output signed [39:0] M ;


assign M = A * B ;


endmodule 