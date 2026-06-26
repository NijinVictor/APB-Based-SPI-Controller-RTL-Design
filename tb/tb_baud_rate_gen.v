`timescale 1ns/1ps

module baudrate_tb;

    reg pclk;
    reg preset_n;
    reg spiswai_i, cpol_i, cpha_i, ss_i;
    reg [1:0] spi_mode_i;
    reg [2:0] sppr_i, spr_i;
    wire sclk;
    wire miso_receive_sclk, miso_receive_sclk0;
    wire mosi_send_sclk, mosi_send_sclk0;
    wire [11:0] baudratedivisor;

    baud_rate_generator DUT ( pclk, preset_n, spiswai_i, cpol_i, cpha_i, ss_i, spi_mode_i, sppr_i, spr_i, sclk, miso_receive_sclk, miso_receive_sclk0, mosi_send_sclk, mosi_send_sclk0, baudratedivisor );

    always
	 begin
		 #5;
		 pclk=1'b0;
		 #5;
		 pclk=1'b1;
	 end
	
	 task reset_n;
	 begin
		  @(negedge pclk)
			 preset_n=1'b0;
		  @(negedge pclk)
			 preset_n=1'b1;
	 end
	 endtask
	
	 initial begin
	 
		{cpol_i,cpha_i}=2'b00;
		reset_n;
		spi_mode_i= 2'b00;
		{sppr_i,spr_i}=6'd1;
		{ss_i,spiswai_i}=2'b00;
		#100;
	
		spi_mode_i=2'b01;
		{cpol_i,cpha_i}=2'b01;
	
		{sppr_i,spr_i}=6'd2;
		{ss_i,spiswai_i}=2'b00;
		#100;
	
		spi_mode_i=2'b00;
		{cpol_i,cpha_i}=2'b10;
		{sppr_i,spr_i}=6'd2;
		{ss_i,spiswai_i}=2'b00;
		#100;
		$finish; 
	
	 end
	 initial 
	   #400 $finish;
endmodule
