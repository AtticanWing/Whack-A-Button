module FPGA
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;		
	input [9:0] SW;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
		wire oDone;
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	  part2 try(KEY[0], KEY[1], CLOCK_50,x,y,colour,writeEn,oDone);
	// for the VGA controller, in addition to any other functionality your design may require.
	
	
endmodule


//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iBlack,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iBlack;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame

   //
   // Your code goes here
   //
	wire ld_colour, ld_result;
	
	wire print_black, link;


    control C0(
        .clk(iClock),
        .resetn(iResetn),

		  .iBlack(iBlack),
		  
		  .link(link),

		  .ld_result(ld_result),
		  
		  .print_black(print_black)		  
        
    );

    datapath #(X_SCREEN_PIXELS,Y_SCREEN_PIXELS)D0(
        .clk(iClock),
        .resetn(iResetn),

		  .ld_result(ld_result),
		  
		  .print_black(print_black),
		  
		  .link(link),

        .ox_result(oX),
		  .oy_result(oY),

		  .oColour(oColour),
		  .oDone(oDone),
		  .oPlot(oPlot)
    );

 endmodule


module control(
    input clk,
    input resetn,
	 input iBlack,
	 input link,

    output reg ld_result,
	 output reg print_black

    );

    reg [3:0] current_state, next_state;

    localparam  S_WAIT						= 4'd0,
					 S_BLACK   					= 4'd1,
					 S_PRINT_BLACK	  			= 4'd2;	

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
					 S_WAIT: begin
						 if(iBlack==1'b1)
								next_state = S_BLACK; // Loop in current state until value is input;
						 else
								next_state = S_WAIT;
						 end
					 S_BLACK: begin
						 if(iBlack==1'b0)
								next_state = S_PRINT_BLACK; // Loop in current state until value is input
						 else
								next_state = S_BLACK;
						 end
					 S_PRINT_BLACK: begin
						 if(iBlack==1'b1)
								next_state = S_BLACK; // Loop in current state until value is input
						 else if(link == 1'b1)
								next_state = S_WAIT;
						 else
								next_state = S_PRINT_BLACK;
						 end

                
            default:     next_state = S_WAIT;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0

		  print_black = 1'b0;
		  ld_result = 1'b0;


        case (current_state)
				S_WAIT: begin
					print_black = 1'b0;
					ld_result = 1'b0;
                end	
				S_PRINT_BLACK: begin
					 print_black = 1'b1;
					 end			
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
			  begin
					current_state <= S_WAIT;
			  end
		  else
            current_state <= next_state;				
    end // state_FFS
endmodule

module datapath #(parameter X_SCREEN_PIXELS,Y_SCREEN_PIXELS)(
    input clk,
    input resetn,
    input ld_result,
	 
	 input  print_black,
	 
	 output reg link,
    output reg [7:0] ox_result,
	 output reg [6:0] oy_result,

	 output reg [2:0] oColour,
	 output reg oDone,
	 output reg oPlot
    );

    // input registers
	 
	 reg[7:0] blackxcounter;
	 reg[6:0] blackycounter;
	 
	 parameter radius = 30;
	 parameter firstcirclex = 35;
    parameter firstcircley = 60;
	 parameter secondcirclex = 125;
    parameter secondcircley = 60;


    // Print result register
    always@(posedge clk) begin
        if(!resetn) begin
				oPlot =1'b0;
				oDone = 1'b0;
            ox_result = 8'b0;
				oy_result = 7'b0;
				oColour= 3'b0;

				blackxcounter= 12'b0;
				blackycounter= 12'b0;
				link = 1'b0;
        end
        else 
		  begin
				if(link==1)begin			
					oDone <= 1'b1;
					link=1'b0;
					blackxcounter= 12'b0;
					blackycounter= 12'b0;
					oPlot =1'b0;
				end
				else if(print_black)
					begin
						if((blackxcounter==X_SCREEN_PIXELS) &(blackycounter==Y_SCREEN_PIXELS)) begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							oColour<= 3'b110;
							oPlot<=1'b1;
							oDone <=1'b0;
							link=1'b1;
						end
						
						else if(blackxcounter==(X_SCREEN_PIXELS))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackycounter <=blackycounter+1;
							blackxcounter <= 12'b000000000000;
							oColour<= 3'b110;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						
						else if(blackxcounter>=(X_SCREEN_PIXELS/2)&blackycounter<=9)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b111;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if(blackxcounter<=(X_SCREEN_PIXELS/2-1)&blackycounter>(Y_SCREEN_PIXELS-9))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b111;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if(blackxcounter%7==0&blackxcounter<=(X_SCREEN_PIXELS/2-1)&blackycounter<=9)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b010;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if(blackxcounter%7==0&blackxcounter>=(X_SCREEN_PIXELS/2)&blackycounter>(Y_SCREEN_PIXELS-9))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b001;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if(blackxcounter==70&blackycounter<=35&blackycounter>=15)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if(blackxcounter==80&blackycounter<=35&blackycounter>=15)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if(blackxcounter==90&blackycounter<=35&blackycounter>=15)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if(blackxcounter>=70&blackxcounter<=90&blackycounter==35)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if(blackxcounter>=70&blackxcounter<=90&blackycounter==50)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if(blackxcounter>=70&blackxcounter<=90&blackycounter==67)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if((blackxcounter==70|blackxcounter==90)&blackycounter<=75&blackycounter>=50)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						
						else if((blackxcounter==80|blackxcounter==70|blackxcounter==90)&blackycounter>=90&blackycounter<=110)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if(blackxcounter>=70&blackxcounter<=90&blackycounter==90)begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						end
						else if((blackxcounter-firstcirclex)*(blackxcounter-firstcirclex)==((radius)*(radius)-(blackycounter-firstcircley)*(blackycounter-firstcircley)))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if((blackxcounter-firstcirclex)*(blackxcounter-firstcirclex)+(blackycounter-firstcircley)*(blackycounter-firstcircley)<(radius*radius))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b100;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if((blackxcounter-secondcirclex)*(blackxcounter-secondcirclex)==(radius*radius-(blackycounter-secondcircley)*(blackycounter-secondcircley)))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b000;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if((blackxcounter-secondcirclex)*(blackxcounter-secondcirclex)+(blackycounter-secondcircley)*(blackycounter-secondcircley)<(radius*radius))begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b101;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						
						else if(blackxcounter<(X_SCREEN_PIXELS/2)) begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b110;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						else if(blackxcounter<(X_SCREEN_PIXELS)) begin
							ox_result <= blackxcounter;
							oy_result <= blackycounter;
							blackxcounter <=blackxcounter+1;
							oColour<= 3'b011;
							oPlot<=1'b1;
							oDone <=1'b0;
						
						end
						
					
					end
				else begin
					link = 1'b0;
				
				end
			
		  end
    end



endmodule

