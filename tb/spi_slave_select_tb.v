`timescale 1ns/1ps

module spi_slave_select_tb;

reg        pclk;
reg        preset_n;
reg        mstr_i;
reg        spiswai_i;
reg        senddata_i;
reg  [1:0] spimode_i;
reg [11:0] Baudratedivisor;

wire       ss_o;
wire       tip_o;
wire       receivedata_i;

spi_slave_select dut (
    .pclk(pclk),
    .preset_n(preset_n),
    .mstr_i(mstr_i),
    .spiswai_i(spiswai_i),
    .send_data_i(senddata_i),
    .spi_mode_i(spimode_i),
    .baudratedivisor_i(Baudratedivisor),
    .ss_o(ss_o),
    .tip_o(tip_o),
    .receive_data_o(receivedata_i)
);

initial pclk = 1'b0;
always #5 pclk = ~pclk;

task reset;
begin
    @(negedge pclk);
    preset_n = 1'b0;
    @(negedge pclk);
    preset_n = 1'b1;
end
endtask

task senddata;
begin
    @(negedge pclk);
    senddata_i = 1'b1;
    @(negedge pclk);
    senddata_i = 1'b0;
end
endtask

task stimulus(input a, input b, input [1:0] mode, input [11:0] bauddata);
begin
    @(negedge pclk);
    mstr_i = a;
    spiswai_i = b;
    spimode_i = mode;
    Baudratedivisor = bauddata;
end
endtask

initial begin
    preset_n = 1'b1;
    mstr_i = 1'b0;
    spiswai_i = 1'b0;
    senddata_i = 1'b0;
    spimode_i = 2'b00;
    Baudratedivisor = 12'd0;

    reset;

    stimulus(1'b1, 1'b0, 2'b00, 12'd4);

    senddata;

    #800;

    $finish;
end

endmodule
