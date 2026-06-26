module spislave(pclk,preset_n,mstr_i,spiswai_i,spimode_i,senddata_i,Baudratedivisor,receivedata_i,ss_o,tip_o);

input pclk,preset_n,mstr_i,spiswai_i,senddata_i;
input [1:0]spimode_i;
input [11:0]Baudratedivisor;
output reg receivedata_i;
output reg ss_o;
output tip_o;

wire [15:0]target;
reg [15:0]count;

assign target = Baudratedivisor * 8;

reg rcv_s;
always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
	  begin
	     count<=16'hffff;
             ss_o<=1'b1;
	     rcv_s<=1'b0;
          end
	else if((mstr_i) && ((spimode_i==2'b00)||((!spiswai_i)&&(spimode_i==2'b01))))
	begin
		if(senddata_i == 1'b1)
		begin
			ss_o<=1'b0;
			count<=16'd0;
		end
		else
		begin
			if(count<(target-1'b1))
				begin
					ss_o<=1'b0;
					rcv_s<=1'b0;
					count<=count+1;
				end
                        else if(count==(target-1'b1))
			begin
  				rcv_s<=1'b1;
				count<=count+1;
				ss_o<=1'b0;
			end
			else if(count==target)
			begin
				rcv_s<=1'b1;
				ss_o<=1'b1;
				count<=count+1;
			end
			else
			begin
				ss_o<=1;
				rcv_s<=1'b0;
			end
		end	
	end
        else	
	begin
		ss_o<=1'b1;
		rcv_s<=1'b0;
		count<=16'hffff;
	end
             
end
assign tip_o=~ss_o;

always@(posedge pclk,negedge preset_n)
begin
	if(!preset_n)
		receivedata_i<=1'b0;
	else
		receivedata_i<=rcv_s;
end

endmodule
