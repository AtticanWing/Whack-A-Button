
module audio (
	// Inputs
	CLOCK_50,
	KEY,
	start,
	gameover,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[1:0]	KEY;
input		[4:0]	SW;
input 	start;
input 	gameover;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

// Internal Registers

reg [19:0] delay_cnt; //counter that counts down w/ freq of note

reg snd;
wire playnext;

// State Machine Registers
musicDivider songrate(CLOCK_50, ~KEY[0], playnext);


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

reg [19:0] note;
reg [5:0] state;
reg pressed;

always @(posedge CLOCK_50) begin
	
	if (gameover == 1'b0) begin
		if (SW[0]) begin
			note<= 20'd113636; //A4
			pressed = 1'b1;
		end
		else if (SW[1]) begin
			note<= 20'd101238; //B4
			pressed = 1'b1;
		end
		else if (SW[2]) begin
			note<= 20'd90193; //C#4
			pressed = 1'b1;
		end
		else if (SW[3]) begin
			note<= 20'd85131; //D4
			pressed = 1'b1;
		end
		else if (SW[4]) begin
			note<= 20'd75843; //E4
			pressed = 1'b1;
		end
		else begin
			note <= 20'd113636; //A4
			pressed = 1'b0;
		end
		//delay_cnt <= (delay_cnt == 0) ? note : delay_cnt - 9'd1;
		/*if (delay_cnt == 0) begin
			delay_cnt <= note;
			snd <= !snd;
		end else delay_cnt <= delay_cnt-1;*/
	end
	else begin
		pressed = 1'b1;
		case(state)
			0: begin
				note <= 20'd95556; //C5
				if (playnext) state <= 1;
				else state <= 0;
				end
			1: begin
				note <= 20'd95556; //C5
				if (playnext) state <= 2;
				else state <= 1;
				end
			2: begin
				note <= 20'd95556; //C5
				if (playnext) state <= 3;
				else state <= 2;
				end
			3: begin
				note <= 20'd95556; //C5
				if (playnext) state <= 4;
				else state <= 3;
				end
			4: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 5;
				else state <= 4;
				end
			5: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 6;
				else state <= 5;
				end
			6: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 7;
				else state <= 6;
				end
			7: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 8;
				else state <= 7;
				end
			8: begin
				note <= 20'd151686; //E4
				if (playnext) state <= 9;
				else state <= 8;
				end
			9: begin
				note <= 20'd151686; //E4
				if (playnext) state <= 10;
				else state <= 9;
				end
			10: begin
				note <= 20'd151686; //E4
				if (playnext) state <= 11;
				else state <= 10;
				end
			11: begin
				note <= 20'd113636; //A4
				if (playnext) state <= 12;
				else state <= 11;
				end
			12: begin
				note <= 20'd113636; //A4
				if (playnext) state <= 13;
				else state <= 12;
				end
			13: begin
				note <= 20'd101238; //B4
				if (playnext) state <= 14;
				else state <= 13;
				end
			14: begin
				note <= 20'd101238; //B4
				if (playnext) state <= 15;
				else state <= 14;
				end
			15: begin
				note <= 20'd113636; //A4
				if (playnext) state <= 16;
				else state <= 15;
				end
			16: begin
				note <= 20'd113636; //A4
				if (playnext) state <= 17;
				else state <= 16;
				end
			17: begin
				note <= 20'd120394; //Ab4
				if (playnext) state <= 18;
				else state <= 17;
				end
			18: begin
				note <= 20'd120394; //Ab4
				if (playnext) state <= 19;
				else state <= 18;
				end
			19: begin
				note <= 20'd120394; //Ab4
				if (playnext) state <= 20;
				else state <= 19;
				end
			20: begin
				note <= 20'd107258; //Bb4
				if (playnext) state <= 21;
				else state <= 20;
				end
			21: begin
				note <= 20'd107258; //Bb4
				if (playnext) state <= 22;
				else state <= 21;
				end
			22: begin
				note <= 20'd107258; //Bb4
				if (playnext) state <= 23;
				else state <= 22;
				end
			23: begin
				note <= 20'd120394; //Ab4
				if (playnext) state <= 24;
				else state <= 23;
				end
			24: begin
				note <= 20'd120394; //Ab4
				if (playnext) state <= 25;
				else state <= 24;
				end
			25: begin
				note <= 20'd120394; //Ab4
				if (playnext) state <= 26;
				else state <= 25;
				end
			26: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 27;
				else state <= 26;
				end
			27: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 28;
				else state <= 27;
				end
			28: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 29;
				else state <= 28;
				end
			29: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 30;
				else state <= 29;
				end
			30: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 31;
				else state <= 30;
				end
			31: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 32;
				else state <= 31;
				end
			32: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 33;
				else state <= 32;
				end
			33: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 34;
				else state <= 33;
				end
			34: begin
				note <= 20'd127553; //G4
				if (playnext) state <= 35;
				else state <= 34;
				end
			35: begin
				note <= 20'd0; //no note until start again
				if (start) state <= 0;
				else state <= 35;
				end
			default: note <= 20'd95556; //C5
		endcase
	end
end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50) begin
	if (delay_cnt == 0) begin
		delay_cnt <= note; //div by fullnote to get 50Mhz/fullnoteHz note
		snd <= !snd;
	end else delay_cnt <= delay_cnt -1;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

wire [31:0] sound = (pressed == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in+sound;
assign right_channel_audio_out	= right_channel_audio_in+sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

module musicDivider (input clk, input resetn, output next);
	localparam CLOCK_FREQUENCY = 50000000;

	reg[27:0] downCount;
	
	always@(posedge clk)
		begin
			if ((downCount==27'd0)||(resetn))
					downCount<= 1*CLOCK_FREQUENCY/8;//0.5 second
			else
			begin
					downCount<=downCount-1'b1;
			end
			
		end
	assign next=(downCount==27'd0)? 1'b1:1'b0;
endmodule