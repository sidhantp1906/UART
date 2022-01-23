`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:22:21 01/12/2022 
// Design Name: 
// Module Name:    uart_rx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_rx(
    input rx,
    input s_tick,
    input clk,
    input reset,
    output [7:0] dataout,
    output reg rx_done
    );
	 
	 
	 reg [1:0]cur_s,nex_s;
	 parameter idle = 2'b00,start = 2'b01,data_s = 2'b10,stop = 2'b11;
	 reg [2:0]nreg,nnex;
	 reg [3:0]sreg,snex;
	 reg [7:0]breg,bnex;
	
always @(posedge clk)
begin
if(~reset)
begin
	cur_s <= idle;
	nreg <= 0;
	sreg <= 0;
	breg <= 0;
end
else
begin
cur_s <= nex_s;
	nreg <= nnex;
	sreg <= snex;
	breg <= bnex;
end
end

always @(posedge clk or cur_s)
begin
nex_s = cur_s;
nnex = nreg;
snex = sreg;
bnex = breg;
rx_done = 0;
case(cur_s)
idle:begin
		if(rx)
		begin
		snex = 0;
		nex_s = start;
		end
	  end
start:begin
			if(s_tick)
			begin
				if(sreg == 4'hf)
				begin
					snex = 0;
					nnex = 0;
					nex_s = data_s;
				end
				else
				snex = sreg +1;
			end
		end
data_s:begin
		if(s_tick)
		begin
				if(sreg == 4'hf)
				begin
					snex = 0;
					bnex = {rx,breg[7:1]};
					if(nreg == 3'b111)
					nex_s = stop;
					else
					nnex = nreg + 1;
				end
				else
				snex = sreg +1;
		end
	  end
stop:begin
		if(s_tick)
		begin
			if(sreg == 4'hf)
			begin
				rx_done = 1;
				nex_s = idle;
			end
			else
			snex = sreg+1;
		end
	  end
endcase
end

assign dataout = breg;

endmodule
