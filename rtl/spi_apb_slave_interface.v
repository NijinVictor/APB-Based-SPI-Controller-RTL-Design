
module apb_slave(pclk,preset_n,paddr_i,pwrite_i,psel_i,penable_i,pwdata_i,ss_i,miso_data_i,receive_data_i,tip_i,prdata_o,mstr_o,cpol_o,cphase_o,lsbfe_o,spiswai_o,sppr_o,spr_o,spi_interrupt_req_o,pready_o,pslverr_o,send_data_o,mosi_data_o,spimode_o);

input pclk,preset_n,pwrite_i,psel_i,penable_i,ss_i,receive_data_i,tip_i;
input [2:0]paddr_i;
input [7:0]pwdata_i,miso_data_i;

output reg [7:0]prdata_o;
output mstr_o,cpol_o,cphase_o,lsbfe_o,spiswai_o,spi_interrupt_req_o,pready_o,pslverr_o;
output reg send_data_o;
output reg [7:0]mosi_data_o;
output [2:0]sppr_o,spr_o;
output reg [1:0]spimode_o;

reg [1:0]state,nextstate;
reg [1:0]spi_next;
reg [7:0]SPI_CR1;
reg [7:0]SPI_CR2;
reg [7:0]SPI_BR;
reg [7:0]SPI_SR;
reg [7:0]SPI_DR;

wire  spif,sptie,ssoe,sptef,modf,modfen,spe,bidiroe,spc0;
wire  wr_enb,rd_enb;
parameter IDLE=2'b00,SETUP=2'b01,ENABLE=2'b10;

parameter SPI_RUN=2'b00,SPI_WAIT=2'b01,SPI_STOP=2'b10;

// REGISTER VALUE 


assign spie= SPI_CR1[7];
assign spe = SPI_CR1[6];
assign sptie=SPI_CR1[5];
assign mstr_o=SPI_CR1[4];
assign cpol_o=SPI_CR1[3];
assign cphase_o= SPI_CR1[2];
assign ssoe = SPI_CR1[1];
assign lsbfe_o=SPI_CR1[0];

// CR2

assign spc0=SPI_CR2[0];
assign spiswai_o=SPI_CR2[1];
assign bidiroe = SPI_CR2[3];
assign modfen= SPI_CR2[4];

//BR3

assign sppr_o = SPI_BR[6:4];
assign spr_o =SPI_BR[2:0];

//**********************************************************
//APB FSM


always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
	     state<=IDLE;
        else
	    state<=nextstate;
end

always@(*)
begin
    case(state)
	    IDLE:if(psel_i && !penable_i)
	    		nextstate=SETUP;
		 else
			nextstate=IDLE;
	    SETUP:if(psel_i && penable_i)
	     		nextstate=ENABLE;
		  else if(psel_i && !penable_i)
		 	nextstate=SETUP;
		  else 
			nextstate=IDLE;
	   ENABLE:if(psel_i && !penable_i)
	   		nextstate=SETUP;
		  else 
			nextstate=IDLE;
	   default:nextstate=IDLE;
		endcase
end


//******************************************************************
// SPI FSM

always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
		spimode_o<=SPI_RUN;
	else
		spimode_o<=spi_next;
end
always@(*)
begin
	case(spimode_o)
		SPI_RUN:if(!spe)
			spi_next=SPI_WAIT;
			else
			spi_next=SPI_RUN;
		SPI_WAIT:if(spiswai_o)
			 spi_next=SPI_STOP;
		 	 else if(spe)
			 spi_next=SPI_RUN;
		     	 else
			 spi_next=SPI_WAIT;
		SPI_STOP:if((!(spiswai_o)))
			 spi_next=SPI_WAIT;
		 	 else if(spe)
			 spi_next=SPI_RUN;
		 	 else
			 spi_next=SPI_STOP;
		default:spi_next=SPI_RUN;
	endcase
	
	
end

//PREADY
assign pready_o=(state==ENABLE)?1'b1:1'b0;

assign pslverr_o=(state==ENABLE)?(~tip_i):1'b0;

assign wr_enb=((state==ENABLE)&& (pwrite_i))?(1'b1):1'b0;

assign rd_enb=((state==ENABLE)&&(!pwrite_i))?(1'b1):1'b0;

always@(posedge pclk ,negedge preset_n)
begin
	if(!preset_n)
	begin
		SPI_CR1<=8'b00000100;
		SPI_CR2<=8'd0;
		SPI_BR<=8'd0;
		
	end
	else if(wr_enb)
	begin
		case(paddr_i)
			3'b000:SPI_CR1<=pwdata_i;
			3'b001:SPI_CR2<=pwdata_i & 8'b00011011;
			3'b010:SPI_BR<=pwdata_i & 8'b01110111;
		endcase
	end
	
end

always@(*)
begin
	if(rd_enb)
	begin
		case(paddr_i)
			3'b000:prdata_o=SPI_CR1;
			3'b001:prdata_o=SPI_CR2;
			3'b010:prdata_o=SPI_BR;
			3'b011:prdata_o=SPI_SR;
			3'b101:prdata_o=SPI_DR;
			default:prdata_o=8'd0;
		endcase
	end
	else
		prdata_o=8'd0;

end


assign modf = ((!ss_i)&&(mstr_o)&&(modfen)&&(!ssoe));
assign spi_interrupt_req_o=(!spie && !sptie)?(1'b0):(spie && !sptie)?(spif || modf):(sptie && !spie)?(sptef):(spif || modf || sptef);

assign sptef=(SPI_DR==8'd0);
assign spif=(SPI_DR!=8'd0);

always@(*)
begin
	
	SPI_SR={spif,1'b0,sptef,modf,4'b0000};
end
//
always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
		send_data_o<=1'b0;
	else
	begin
		if(wr_enb)
		     send_data_o<=send_data_o;
	   else
		begin
			if((SPI_DR==pwdata_i && SPI_DR!=miso_data_i) && ((spimode_o==SPI_RUN )||(spimode_o==SPI_WAIT)))
				send_data_o<=1'b1;
			else
			begin
				if(((spimode_o==SPI_RUN) || (spimode_o==SPI_WAIT)))
				  	send_data_o<=1'b0;
				else
					send_data_o<=1'b1;
			end
		end
	end


end

always@(posedge pclk , negedge preset_n)
begin
	if(!preset_n)
		mosi_data_o<=8'd0;
	else
	begin
		if(!wr_enb)
		begin
			if((SPI_DR==pwdata_i && SPI_DR!=miso_data_i)&&((spimode_o==SPI_RUN )||(spimode_o==SPI_WAIT)))
				mosi_data_o<=SPI_DR;
			else
				mosi_data_o<=mosi_data_o;
		end
	end
end

always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
		SPI_DR<=8'd0;
	else
	begin
		if(wr_enb)
		begin
			if(paddr_i==3'b101)
				SPI_DR<=pwdata_i;

			else
				SPI_DR<=SPI_DR;
		end
		else
		begin
			if(SPI_DR==pwdata_i && SPI_DR!=miso_data_i && ((spimode_o==SPI_RUN) || (spimode_o==SPI_WAIT)))
			       SPI_DR<=8'd0;
	       
	       		else
				begin
						if(((spimode_o==SPI_RUN)||(spimode_o==SPI_WAIT))&& (receive_data_i))
							SPI_DR<=miso_data_i;
						else
							SPI_DR<=SPI_DR;
					end
		 end 
 	end	   		

end

endmodule
