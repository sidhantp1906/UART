`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:11:54 01/12/2022 
// Design Name: 
// Module Name:    uart_tx 
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
module uart_tx(
    output tx,
    input [7:0] data,
    output reg tx_done,
    input s_tick,
    input tx_start,
    input clk,
    input reset
    );
	 
uart_rx rx(.rx(tx),.s_tick(s_tick),.clk(clk),.reset(reset),.dataout(dataout),.rx_done(rx_done));

reg [1:0]cur_s,nex_s;
parameter idle = 2'b00,start = 2'b01,data_s = 2'b10,stop = 2'b11;

reg txreg,txnex;
reg [2:0]nreg,nnex;
reg [7:0]breg,bnex;
reg [3:0]sreg,snex;

always @(posedge clk)
begin
	if(~reset)
	begin
		cur_s <= idle;
		breg <= 8'h00;
		sreg <= 4'h0;
		txreg <= 1;
		nreg <= 0;
	end
	else
	begin
		cur_s <= nex_s;
		breg <= bnex;
		sreg <= snex;
		txreg <= txnex; 
		nreg <= nnex;
	end 
end

always @(posedge clk or cur_s)
begin
nex_s = cur_s;
snex = sreg;
bnex = breg;
txnex = txreg;
nnex = nreg;
tx_done = 0;
case(cur_s)
	idle:begin
		txnex = 1;
		if(tx_start)
			begin
				snex = 4'h0;
				bnex = data;
				nex_s = start;
			end
			end
	start:begin
				txnex = 0;
				if(s_tick)
				begin
					if(sreg == 4'hf)
					begin
						snex = 4'h0;
						nnex = 0;
						nex_s = data_s;
					end
					else
					snex = sreg + 1;
				end
			end
	data_s:begin
				txnex = breg[0];
				if(s_tick)
				begin
					if(sreg == 4'hf)
					begin
						snex = 4'b0;
						bnex = {1'b0,breg[7:1]};
						if(nreg == 7)
						nex_s = stop;
						else
						nnex = nreg +1;
					end
					else
					snex = sreg +1;
				end
			 end
	stop:begin
			txnex = 1;
			if(s_tick)
			begin
				if(sreg == 4'hf)
				begin
				tx_done = 1;
				nex_s = idle;
				end
				else
				snex = sreg +1;
			end
		  end

endcase
end

assign tx = txreg;

endmodule
