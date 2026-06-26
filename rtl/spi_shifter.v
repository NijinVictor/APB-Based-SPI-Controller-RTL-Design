module spi_shift(pclk,preset_n,ss_i,send_data_i,lsbfe_i,cphase_i,cpol_i,miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0,data_mosi_i,miso_i,receive_data_i,mosi_o,data_miso_o);

input pclk,preset_n,ss_i,send_data_i,lsbfe_i,cphase_i,cpol_i,miso_receive_sclk,miso_receive_sclk_0,mosi_sent_sclk,mosi_sent_sclk_0,miso_i,receive_data_i;

input [7:0]data_mosi_i;

output reg  mosi_o;
output reg [7:0]data_miso_o;

reg [7:0]shift_reg;
reg [7:0]temp_reg;
reg [2:0]count,count1;
reg [2:0]count2,count3;

always@(posedge pclk ,negedge preset_n)
begin
	if(!preset_n)
	    shift_reg<=8'd0;
        else
	   if(send_data_i)
		shift_reg<=data_mosi_i;
	   else
		shift_reg<=shift_reg;
end	

// mosi
always@(posedge pclk , negedge preset_n)
begin
	if(!preset_n)
	begin
	     mosi_o<=1'b0;
	     count<=3'd0;
	     count1<=3'd7;
       	end
	else
            begin
		    if((!ss_i)&&((!cphase_i && cpol_i)||(cphase_i && !cpol_i)))
		    begin
			    if(lsbfe_i)
			    begin
				  if(count<=7)
				  begin
					  if(mosi_sent_sclk_0)
					  begin
						  mosi_o<=shift_reg[count];
					          count<=count+1;
					  end
					  else
						  mosi_o<=mosi_o;
                                  end
				  else
					  count<=0;
			    end
			    else
			      begin
				   if(count1>=0)
				   begin
					   if(mosi_sent_sclk_0)
					   begin
						   mosi_o<=shift_reg[count];
						   count1<=count1-1;
					   end
					   else
						   mosi_o<=mosi_o;
				   end
				   else
					   count1<=3'd7;
			      end

		    end
		    else if((!ss_i)&&((!cphase_i && !cpol_i)||(cphase_i && cpol_i)))
		    begin
			    if(lsbfe_i)
			    begin
				    if(count<=7)
				    begin
					if(mosi_sent_sclk)
					begin
						mosi_o<=shift_reg[count];
						count<=count+1;
					end
					else
						mosi_o<=mosi_o;
				    end
				    else
					   count<=3'd0;

			    end
			    else
			    begin
				    if(count1>=0)
				    begin
					if(mosi_sent_sclk)
					begin
						mosi_o<=shift_reg[count1];
						count1<=count1-1;
					end
					else
						mosi_o<=mosi_o;
				    end
				    else
					    count1<=3'd7;

			    end
		    end
		    else
			begin
				mosi_o<=1'b0;
				count<=3'd0;
				count1<=3'd7;
			end
	    end
end

////miso   
always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
	begin
		//temp_reg<=8'd0;
	        data_miso_o<=8'd0;
	end
	else
	begin
		if(receive_data_i)
			data_miso_o<=temp_reg;
		else
			data_miso_o<=data_miso_o;
		
	end
end
always@(posedge pclk,negedge preset_n)
begin
       if(!preset_n)
   	begin
		temp_reg<=8'd0;
		count2<=3'd0;
		count3<=3'd7;

	end
	else
	begin
		if((!ss_i)&&((!cphase_i && cpol_i)||(cphase_i && !cpol_i)))
		begin
			if(lsbfe_i)
			begin
				if(count2<=3'd7)
				begin
					if(miso_receive_sclk_0)
					begin
						temp_reg[count2]<=miso_i;
						count2<=count2+1;
					end
					//else
						//temp_reg <=temp_reg;
				end
				else
					count2<=3'd0;
			end
			else
			begin
				if(count3>=0)
				begin
					if(miso_receive_sclk_0)
					begin
						temp_reg[count3]<=miso_i;
						count3<=count3-1;
					end
					//else
						//temp_reg<=temp_reg;
				end
				else
					count3<=3'd7;
			end
		end
		else if((!ss_i)&&((!cphase_i && !cpol_i)||(cphase_i && cpol_i)))
		begin
			if(lsbfe_i)
			begin
				if(count2<=3'd7)
				begin
					if(miso_receive_sclk)
					begin
						temp_reg[count2]<=miso_i;
						count2<=count2+1;
					end
					//else
					//	temp_reg <= temp_reg;
				end
				else
					count2<=3'd0;
			end
			else
			begin
				if(count3>=0)
				begin
					if(miso_receive_sclk)
					begin
						temp_reg[count3]<=miso_i;
						count3<=count3-1;
					end
					//else
					//	temp_reg<=temp_reg;
				end
				else
					count3<=3'd7;
			end
		end
		else
		begin
		 	 count2<=3'd0;
  	         	count3<=3'd7;		  

		end
	end
end

endmodule