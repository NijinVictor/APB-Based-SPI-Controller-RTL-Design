module spi_top_tb();

reg pclk,preset_n,pwrite_i,psel_i,penable_i,miso_i;
reg [7:0]pwdata_i;
reg [2:0]paddr_i;

wire ss_o,sclk_o,spi_interrupt_req_o,mosi_o,pready_o,pslverr_o;
wire [7:0]prdata_o;

apb_spi_top dut(pclk,preset_n,paddr_i,pwrite_i,psel_i,penable_i,pwdata_i,miso_i,ss_o,sclk_o,spi_interrupt_req_o,mosi_o,prdata_o,pready_o,pslverr_o);

task initialize;
	begin
		paddr_i=3'd0;
		penable_i=1'b0;
		miso_i=1'b0;
		pwdata_i=8'd0;
	end
endtask

always
begin
	#5;
	pclk=1'b0;
	#5;
	pclk=1'b1;
end

task rst;
	begin
		@(negedge pclk)
		  preset_n=1'b0;
		@(negedge pclk)
		  preset_n=1'b1;
	end
endtask

task write_stimulus(input sel,wrenb,input [2:0]wraddr,input [7:0]wrdata);
	begin
		@(negedge pclk)
		  psel_i=sel;
		  pwrite_i=wrenb;
		  paddr_i=wraddr;
		  pwdata_i=wrdata;
	end
endtask

task read_stimulus(input sel,wrenb,input [2:0]wraddr);
	begin
		@(negedge pclk)
		  psel_i=sel;
		  pwrite_i=wrenb;
		  paddr_i=wraddr;
	end
endtask
task enable;
	begin
		@(negedge pclk)
		  penable_i=1'b1;
		@(negedge pclk)
		  psel_i=1'b0;
		  penable_i=1'b0;
	end
endtask
task miso(input i);
	begin
		@(negedge pclk)
		  miso_i=i;
		  #40;

	end
endtask

initial begin
initialize;
rst;
write_stimulus(1'b1,1'b1,3'b000,8'b01011111);
enable;

write_stimulus(1'b1,1'b1,3'b001,8'b00000000);
enable;

write_stimulus(1'b1,1'b1,3'b010,8'b00000001);
enable;

write_stimulus(1'b1,1'b1,3'b101,8'b11001100);
enable;
#40;
miso(1'b1);
miso(1'b0);
miso(1'b1);
miso(1'b0);
miso(1'b1);
miso(1'b0);
miso(1'b0);
miso(1'b1);


read_stimulus(1'b1,1'b0,3'b101);
enable;
#30;
$finish;
end

endmodule