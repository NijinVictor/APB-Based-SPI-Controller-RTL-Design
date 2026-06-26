module baudrate(pclk,preset_n,spi_mode_i,spiswai_i,sppr_i,spr_i,cpol_i,cphase_i,ssi,sclk,miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0,Baudratedivisor);


input pclk,preset_n,spiswai_i,cpol_i,cphase_i,ssi;
input [1:0]spi_mode_i;
input [2:0]sppr_i,spr_i;

output reg sclk;
output reg  miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0;
output [11:0]Baudratedivisor;

wire pre_sclk;
reg [12:0]count;
assign pre_sclk=(cpol_i)?(1'b1):1'b0;

assign Baudratedivisor=(sppr_i+1)*(2**(spr_i+1));
always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
	    begin
		sclk<=pre_sclk;
		count<=12'd0;

            end
        else if(((spi_mode_i==2'b00)||((spi_mode_i==2'b01 )&& (!spiswai_i))) && (!ssi))
	    begin
		if(count==((Baudratedivisor/2)-1'b1))
	         begin
		     sclk<=~sclk;
	             count<=12'd0;
		 end
		else
		  begin
	           sclk<=sclk;
		   count<=count+12'd1;
		  end
            end
	else 
        begin
	   sclk<=pre_sclk;
	   count<=12'd0;
         end
end
//MISO CONTENT
always@(posedge pclk, negedge preset_n)
    begin
	  if(!preset_n)
		 begin
			miso_receive_sclk_0 <=1'b0;
			miso_receive_sclk <=1'b0;
    		 end
	  else if((!cphase_i && cpol_i)||(cphase_i && !cpol_i))
	  begin
		  if(sclk==1'b1)
		  begin
			  if(count==((Baudratedivisor/2)-1'b1))
				  miso_receive_sclk_0 <= 1'b1;
			  else
				  miso_receive_sclk_0 <= 1'b0;
		  end
		  else
		         miso_receive_sclk_0 <= 1'b0;
	  end
	  else if((!cphase_i && !cpol_i)||(cphase_i && cpol_i))
	  begin
		  if(sclk==1'b0)
		  begin
			  if(count==((Baudratedivisor/2)-1'b1))
				  miso_receive_sclk <= 1'b1;
			  else
				  miso_receive_sclk <= 1'b0;
		  end
		  else
			  miso_receive_sclk <= 1'b0;
	  end
	  else
	      begin
		      miso_receive_sclk_0 <= miso_receive_sclk_0;
		      miso_receive_sclk <= miso_receive_sclk;
	      end


    end
// MOSI CONTENT 
always@(posedge pclk,negedge preset_n)
      begin
        if(!preset_n)
	begin
		mosi_sent_sclk_0<=1'b0;
		mosi_sent_sclk <=1'b0;
	end
	else if((!cphase_i && cpol_i)||(cphase_i && !cpol_i))
	begin
		if(sclk==1'b1)
		begin
			if(count==((Baudratedivisor/2)-2))
			begin
				mosi_sent_sclk_0<=1'b1;
			end
			else
				mosi_sent_sclk_0 <= 1'b0;

		end
		else
			mosi_sent_sclk_0 <= 1'b0;

	end
        else if((!cphase_i && !cpol_i)||(cphase_i && cpol_i))
	begin
		if(sclk==1'b0)
		begin
			if(count==((Baudratedivisor/2)-2))
			begin
				mosi_sent_sclk <= 1'b1;
			end
			else
				mosi_sent_sclk <= 1'b0;
		end
		else
			mosi_sent_sclk <= 1'b0;
	end
	else
	   begin
		   mosi_sent_sclk<=mosi_sent_sclk;
		   mosi_sent_sclk_0 <= mosi_sent_sclk_0;
	   end
      end

endmodule