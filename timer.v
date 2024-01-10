

module Countdown #(parameter CLOCK_FREQUENCY = 50000000)(
	input ClockIn,
	input realreset,
	input Reset,
	input Speed,//1 is each second 0 is each clock
	output reg[7:0] CounterValue,
	input [0:0] Timer
);
	wire enable;

	RateDivider #(CLOCK_FREQUENCY)firstdivider(ClockIn, Reset, Speed, enable);

	always@(posedge ClockIn)
		begin
			if(Reset==1|!realreset)
				begin
					if(Timer==1'b1)
						begin
							CounterValue<=7'd60;
						end
					else
						begin
							CounterValue<=7'd30;
						end
				end
			else if(enable)
				begin
					if(Timer==1'b1)
						begin
						if(CounterValue>0&CounterValue<= 7'd60)
							CounterValue <= CounterValue -1;
						end
					else if(Timer==1'b0)
						begin
						if(CounterValue>0&CounterValue<= 7'd30)
							CounterValue <= CounterValue -1;
						end
					else
						CounterValue<=0;
				end
		end
	

endmodule

module RateDivider #(parameter CLOCK_FREQUENCY = 50000000)(input ClockIn, input Reset, input Speed, output Enable);

	reg[27:0] downCount;
	
	always@(posedge ClockIn)
		begin
			if ((Reset== 1'b1) ||(downCount==27'd0))
				begin
					if(Speed==1'b1)
						downCount<= CLOCK_FREQUENCY-1;
					else
						downCount<= 27'd0;
				end
			else
				begin
					downCount<=downCount-1'b1;
				end

				
		end
	assign Enable=(downCount==27'd0)? 1'b1:1'b0;
endmodule
	

module hexdisplay(input [3:0]c, output[6:0]display);
	assign display[0] = (~((~c[0]|c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|c[2]|~c[3])&(~c[0]|c[1]|~c[2]|~c[3])));
	
	assign display[1] = (~((~c[0]|c[1]|~c[2]|c[3])&(c[0]|~c[1]|~c[2]|c[3])&(~c[0]|~c[1]|c[2]|~c[3])&(c[0]|c[1]|~c[2]|~c[3])&(~c[0]|~c[1]|~c[2]|~c[3])&(c[0]|~c[1]|~c[2]|~c[3])));
	
	assign display[2] = (~((c[0]|~c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|~c[3])&(~c[0]|~c[1]|~c[2]|~c[3])&(c[0]|~c[1]|~c[2]|~c[3])));
	
	assign display[3] = (~((~c[0]|c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(c[0]|~c[1]|c[2]|~c[3])&(~c[0]|~c[1]|~c[2]|~c[3])));
	
	assign display[4] = (~((~c[0]|c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|c[2]|c[3])&(~c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(~c[0]|c[1]|c[2]|~c[3])));
	
	assign display[5] = (~((~c[0]|c[1]|c[2]|c[3])&(c[0]|~c[1]|c[2]|c[3])&(~c[0]|~c[1]|c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(~c[0]|c[1]|~c[2]|~c[3])));
	
	assign display[6] = (~((c[0]|c[1]|c[2]|c[3])&(~c[0]|c[1]|c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(c[0]|c[1]|~c[2]|~c[3])));
endmodule
