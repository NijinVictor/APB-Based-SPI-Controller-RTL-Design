
module apb_spi_top(pclk,preset_n,paddr_i,pwrite_i,psel_i,penable_i,pwdata_i,miso_i,ss_o,sclk_o,spi_interrupt_req_o,mosi_o,prdata_o,pready_o,pslverr_o);
input pclk,preset_n,pwrite_i,psel_i,penable_i,miso_i;
input [7:0]pwdata_i;
input [2:0]paddr_i;

output ss_o,sclk_o,spi_interrupt_req_o,mosi_o,pready_o,pslverr_o;
output [7:0]prdata_o;

// APB SLAVE
wire [1:0]spimode_o;
wire mstr_o,cpol_o,cphase_o,lsbfe_o,spiswai_o,send_data_o;
wire [2:0]sppr_o,spr_o;
wire [7:0]data_mosi_o;

// Baudrate 
wire miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0;
wire [11:0]baudrate_divisor;

//Slave select
wire receive_data_o,tip_o;

// shiftreg
wire [7:0]data_miso_o; 

baudrate T1(pclk,preset_n,spimode_o,spiswai_o,sppr_o,spr_o,cpol_o,cphase_o,ss_o,sclk_o,miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0,baudrate_divisor);

spislave T2(pclk,preset_n,mstr_o,spiswai_o,spimode_o,send_data_o,baudrate_divisor,receive_data_o,ss_o,tip_o);

spi_shift T3(pclk,preset_n,ss_o,send_data_o,lsbfe_o,cphase_o,cpol_o,miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0,data_mosi_o,miso_i,receive_data_o,mosi_o,data_miso_o);

apb_slave T4(pclk,preset_n,paddr_i,pwrite_i,psel_i,penable_i,pwdata_i,ss_o,data_miso_o,receive_data_o,tip_o,prdata_o,mstr_o,cpol_o,cphase_o,lsbfe_o,spiswai_o,sppr_o,spr_o,spi_interrupt_req_o,pready_o,pslverr_o,send_data_o,data_mosi_o,spimode_o);

endmodule
