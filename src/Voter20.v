/////////////////////////////////////////////////////////
////////    module : Voter20         		     ////////
////////    Editor : Cheng Yu Lin         		 ////////
////////    Last edit : 2021/8/21 22:40          //////// 
////////    Intro : A 20-bit voter with error    ////////
////////    detector                             ////////
/////////////////////////////////////////////////////////

//`timescale 1ns/10ps

module Voter20(
    A, B, C, V,
    error
) ;

input [19:0] A, B, C ;

output reg [1:0] error ;
output reg [19:0] V ;

wire [19:0] V0, V1, V2 ;


assign E0 = (A==B) ;
assign E1 = (A==C) ; 
assign E2 = (B==C) ;

always @(*) begin
    if (!E0 & E2) begin          // A is false 
        V <= B ;
        error <= 1 ;
    end

    else if (!E0 & E1) begin     // B is false
        V <= A ;
        error <= 2 ;
    end

    else if (E0 & !E1) begin     // C is false
        V <= A ;
        error <= 3 ;
    end

    else begin                   // there is no error
        V <= A ;
        error <= 0 ;    
    end 
end


endmodule 