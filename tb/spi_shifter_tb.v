`timescale 1ns/1ps

module spi_shifter_tb;

reg pclk, preset_n, ss_i, send_data_i, receive_data_i, cpol_i, cpha_i, lsbfe_i;

reg [7:0] data_mosi_i;
reg miso_i, mosi_send_sclk_i, mosi_send_sclk0_i, miso_receive_sclk_i, miso_receive_sclk0_i;

wire mosi_o;
wire [7:0] data_miso_o;

spi_shifter dut (
    .pclk(pclk), .preset_n(preset_n),.ss_i(ss_i),.send_data_i(send_data_i),.receive_data_i(receive_data_i),.cpol_i(cpol_i),.cpha_i(cpha_i),.lsbfe_i(lsbfe_i),.data_mosi_i(data_mosi_i),.miso_i(miso_i),.mosi_send_sclk_i(mosi_send_sclk_i),.mosi_send_sclk0_i(mosi_send_sclk0_i),.miso_receive_sclk_i(miso_receive_sclk_i),.miso_receive_sclk0_i(miso_receive_sclk0_i),.mosi_o(mosi_o),.data_miso_o(data_miso_o)
);

always begin
    #5;
    pclk = 1'b0;
    #5;
    pclk = 1'b1;
end

task rst;
begin
    @(negedge pclk);
    preset_n = 1'b0;
    @(negedge pclk);
    preset_n = 1'b1;
end
endtask

task select;
    input       ss;
    input [1:0] mode;
    input       lsbfe;
begin
    @(negedge pclk);
    ss_i    = ss;
    cpol_i  = mode[0];
    cpha_i  = mode[1];
    lsbfe_i = lsbfe;
end
endtask

task datain;
    input [7:0] data;
begin
    @(negedge pclk);
    data_mosi_i = data;
end
endtask

task senddata;
begin
    @(negedge pclk);
    send_data_i = 1'b1;
    @(negedge pclk);
    send_data_i = 1'b0;
end
endtask

task receivedata;
begin
    @(negedge pclk);
    receive_data_i = 1'b1;
    @(negedge pclk);
    receive_data_i = 1'b0;
end
endtask

task mosi_sig;
begin
    @(negedge pclk);
    mosi_send_sclk_i = 1'b1;
    @(negedge pclk);
    mosi_send_sclk_i = 1'b0;
end
endtask

task mosi_sig0;
begin
    @(negedge pclk);
    mosi_send_sclk0_i = 1'b1;
    @(negedge pclk);
    mosi_send_sclk0_i = 1'b0;
end
endtask

task miso_sig;
begin
    @(negedge pclk);
    miso_i = $random;
    miso_receive_sclk_i = 1'b1;
    @(negedge pclk);
    miso_receive_sclk_i = 1'b0;
end
endtask

task miso_sig0;
begin
    @(negedge pclk);
    miso_i = $random;
    miso_receive_sclk0_i = 1'b1;
    @(negedge pclk);
    miso_receive_sclk0_i = 1'b0;
end
endtask

initial begin
    rst;

    select(1'b0, 2'b00, 1'b0);
    datain(8'b0001_1011);
    senddata;

    repeat (8) mosi_sig;
    #50;

    repeat (8) miso_sig;
    receivedata;
    #50;

    rst;
    select(1'b0, 2'b10, 1'b0);
    datain(8'b1010_0101);
    senddata;

    repeat (8) mosi_sig0;
    #50;

    repeat (8) miso_sig0;
    receivedata;
    #50;

    rst;
    select(1'b0, 2'b00, 1'b1);
    datain(8'b1001_0110);
    senddata;

    repeat (8) mosi_sig;
    #50;

    repeat (8) miso_sig;
    receivedata;
    #50;

    ss_i = 1'b1;
    #50;

    $finish;
end

endmodule