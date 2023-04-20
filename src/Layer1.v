//`timescale 1ns/10ps

module Layer1(clk, reset, finish, crd, cwr, csel, caddr_rd, cdata_rd, caddr_wr, cdata_wr, Finish);

input clk, reset, finish;
input [19:0] cdata_rd;

output reg crd, cwr;
output reg [2:0]  csel;
output reg [11:0] caddr_rd, caddr_wr;
output reg [19:0] cdata_wr;
output Finish;

reg [11:0] addr;
reg [2:0] cs, ns;
reg [2:0] countS1;
reg [5:0] countS2;
reg count_ker, enS1, enS2;

wire switch, count_en;


parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100;


//To calculate the current accumulating times of the addresses and the datas have been read and utilized.
//one block for four times a cycle

always @ (posedge clk or posedge reset)
	if (reset)
		countS1 <= 3'd0;
	else if(countS1==4 || cs ==4)
		countS1 <= 3'd0;
	else if(enS1&&ns==1)	
		countS1 <= countS1 + 3'd1;
	else
		countS1 <= countS1;

		
//To determine the number needed to add with the current read address to access the next address to be read.

always @ (*)
	case(countS1)
	3'b000: addr <= 1;
	3'b001: addr <= 63;
	3'b010: addr <= 1;
	3'b011: addr <= -63;
	default: addr <= 0;
	endcase

//To calculate the current accumulating times of the blocks.
//One block acomplished means one max-pooling cycle has finished.
//8 times a cycle  	

always @ (posedge clk or posedge reset)
	if (reset)
		countS2 <= 6'd0;
	else if (cs==4)
		countS2 <= 6'd0;
	else if(enS2)	
		countS2 <= countS2 + 6'd1;
	else
		countS2 <= countS2;
		
always @ (posedge clk or posedge reset)
	if(reset)
		caddr_rd <= -1;
	else if(count_en)
		caddr_rd <= (countS2==63) ? (caddr_rd + 1) : (caddr_rd + addr);
	else
		caddr_rd <= caddr_rd;

				
always @ (posedge clk or posedge reset) 
	if(reset) 
		cs <= S0 ;
	else 
		cs <= ns ;
	

always @ (*)
	case(cs)
		S0:begin
			csel <= 3'b000;
			crd <= 1'b0;
			cwr <= 1'b0;
			enS1 <= 1'b0;
			enS2 <= 1'b0;
			end
		S1:begin
			csel <= (~count_ker) ? 3'b010 : 3'b001;
			crd <= 1'b1;
			cwr <= 1'b0;
			enS1 <= 1'b1;
			enS2 <= 1'b0;
			end
		S2:begin
			csel <= (~count_ker) ? 3'b100 : 3'b011;
			crd <= 1'b0;
			cwr <= 1'b1;
			enS1 <= 1'b1;
			enS2 <= 1'b1;
			end
		S3:begin
			csel <= 3'b000;
			crd <= 1'b0;
			cwr <= 1'b0;
			enS1 <= 1'b1;
			enS2 <= 1'b1;
			end
		S4:begin
			csel <= 3'b000;
			crd <= 1'b0;
			cwr <= 1'b0;
			enS1 <= 1'b0;
			enS2 <= 1'b0;
			end
		default:begin
			csel <= 3'b000;
			enS1 <= 1'b1;
			enS2 <= 1'b0;
			crd <= 1'b0;
			cwr <= 1'b0;
			end
	endcase

always @ (posedge clk or posedge reset)
	if(reset)
		cdata_wr <= 20'd0;
	else if (cs ==3 || cs ==4)
		cdata_wr <= 20'd0;
	else if (enS1 || enS2)
		cdata_wr <= (cdata_rd > cdata_wr) ? cdata_rd : cdata_wr;
	else 
		cdata_wr <= 20'd0;


//next state generator

always @ (*) 
	if (reset) 
		ns <= S0 ;
	else begin
		case (cs) 
			S0: ns <= (finish) ? S1 : S0;
			S1: ns <= (countS1==3) ? S2 : S1;
			S2: ns <= (switch) ? S4 : S3;
			S3: ns <= S1;
			S4: ns <= (count_ker) ? S0 : S1;
			default: ns <= S0;
		endcase 
	end 

always @ (posedge clk or posedge reset)
	if(reset)
		caddr_wr <= 12'd0;
	else if(switch && ns==4)
		caddr_wr <= 12'd0;
	else if(cwr)
		caddr_wr <= caddr_wr + 1;
	else
		caddr_wr <= caddr_wr;
	
always @ (posedge clk or posedge reset)
	if(reset)
		count_ker <= 1;
	else if(switch && cs==3)
		count_ker <= count_ker + 1;
	else
		count_ker <= count_ker;
		
		
assign count_en = (ns==1) ? 1'b1 : 1'b0;
assign switch = &(caddr_wr[9:0]);
assign Finish = (cs==S4) && (ns==S0);

endmodule