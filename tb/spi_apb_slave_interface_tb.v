`timescale 1ns/1ps

module spi_apb_slave_interface_tb;

reg PCLK, PRESETn;

reg [2:0] PADDR;
reg PWRITE, PSEL, PENABLE;
reg [7:0] PWDATA;
reg ss_i;
reg [7:0] miso_data_i;
reg receive_data_i, tip_i;

wire [7:0] PRDATA;
wire PREADY, PSLVERR, spi_interrupt_request_o, send_data_o, mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, spe_o, ssoe_o;
wire [2:0] sppr_o, spr_o;
wire [7:0] mosi_data_o;
wire [1:0] spi_mode_o;

spi_apb_slave_interface dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .ss_i(ss_i),
    .miso_data_i(miso_data_i),
    .receive_data_i(receive_data_i),
    .tip_i(tip_i),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .spi_interrupt_request_o(spi_interrupt_request_o),
    .send_data_o(send_data_o),
    .mstr_o(mstr_o),
    .cpol_o(cpol_o),
    .cpha_o(cpha_o),
    .lsbfe_o(lsbfe_o),
    .spiswai_o(spiswai_o),
    .spe_o(spe_o),
    .ssoe_o(ssoe_o),
    .sppr_o(sppr_o),
    .spr_o(spr_o),
    .mosi_data_o(mosi_data_o),
    .spi_mode_o(spi_mode_o)
);

always begin
    #5;
    PCLK = 1'b0;
    #5;
    PCLK = 1'b1;
end

task rst;
begin
    @(negedge PCLK);
    PRESETn = 1'b0;
    @(negedge PCLK);
    PRESETn = 1'b1;
end
endtask

task apb_write;
    input [2:0] addr;
    input [7:0] data;
begin
    @(negedge PCLK);
    PADDR   = addr;
    PWDATA  = data;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b0;

    @(negedge PCLK);
    PENABLE = 1'b1;

    @(negedge PCLK);
    PSEL    = 1'b0;
    PENABLE = 1'b0;
    PWRITE  = 1'b0;
    PADDR   = 3'b000;
    PWDATA  = 8'h00;
end
endtask

task apb_read;
    input [2:0] addr;
begin
    @(negedge PCLK);
    PADDR   = addr;
    PWRITE  = 1'b0;
    PSEL    = 1'b1;
    PENABLE = 1'b0;

    @(negedge PCLK);
    PENABLE = 1'b1;

    @(negedge PCLK);
    PSEL    = 1'b0;
    PENABLE = 1'b0;
    PADDR   = 3'b000;
end
endtask

task receive_data;
    input [7:0] data;
begin
    @(negedge PCLK);
    miso_data_i    = data;
    receive_data_i = 1'b1;

    @(negedge PCLK);
    receive_data_i = 1'b0;
end
endtask

initial begin
    PRESETn = 1'b1;

    PADDR   = 3'b000;
    PWRITE  = 1'b0;
    PSEL    = 1'b0;
    PENABLE = 1'b0;
    PWDATA  = 8'h00;

    ss_i = 1'b1;
    miso_data_i = 8'h00;
    receive_data_i = 1'b0;
    tip_i = 1'b0;

    rst;

    apb_read(3'd0);   
    #20;
    apb_read(3'd3);  
    #20;
    apb_write(3'd0, 8'h50);
    #30;
    apb_write(3'd1, 8'h00);
    #30;
    apb_write(3'd2, 8'h01);
    #30;
    apb_write(3'd5, 8'hA5);
    #50;
    tip_i = 1'b1;
    #80;
    tip_i = 1'b0;
    receive_data(8'h3C);
    #50;
    apb_read(3'd5);
    #50;
    apb_read(3'd3);
    #50;
    apb_write(3'd1, 8'b0000_0010);
    #50;
    apb_write(3'd0, 8'h00);
    #50;

    $finish;
end

endmodule