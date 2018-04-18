`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:45:32 04/10/2018 
// Design Name: 
// Module Name:    frogger 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module frogger(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, btnU, btnD, btnR, btnL,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	input ClkPort, Sw0, btnU, btnD, btnR, btnL, Sw0, Sw1;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg vga_r, vga_g, vga_b;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	
	
	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	
	
	//counter counter1(.out(cnt1), .enable(1'b1), .clk(DIV_CLK[21]), .reset(1'b0));
	//counter counter2(.out(cnt2), .enable(1'b1), .clk(DIV_CLK[26]), .reset(1'b0));
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] position;
	reg [9:0] h_position;
	reg [9:0] cnt, cnt2, cnt3;
	
	assign orig = (state==newlife);
	always @(posedge DIV_CLK[21], posedge orig)
		begin
			if(orig || (state==newgame) || (state==done))
				begin
					
					position<=470;
					h_position<=240;
				end
			else if(btnD && ~btnU)
				position<=position+frogs;
			else if(btnU && ~btnD)
				position<=position-frogs;
			else if(btnR && ~btnL)
				h_position<=h_position+frogs;
			else if(btnL && ~btnR)
				h_position<=h_position-frogs;
		end
	
	always @(posedge DIV_CLK[24], posedge orig)
		begin
			if(reset || (cnt>480) || (orig||(state==done))) 
				begin
					cnt<=0;
				end
			else
				cnt<=cnt+(5*(4-frogs));
		end
	always @(posedge DIV_CLK[23], posedge orig)
		begin
			if(reset || (cnt2>480) || (orig||(state==done)))
				begin
					cnt2<=0;
				end
			else
				cnt2<=cnt2+(5*(4-frogs));
		end
	always @(posedge DIV_CLK[22], posedge orig)
		begin
			if(reset || (cnt3>480) || (orig||(state==done)))
				begin
					cnt3<=0;
				end
			else
				cnt3<=cnt3+(5*(4-frogs));
		end
		
	wire frog = CounterY>=(position-10) && CounterY<=(position+10) && CounterX>=(h_position-10) && CounterX<=(h_position+10);
	//wire R = CounterX>(cnt) && CounterX<(50+cnt) && CounterY[5:3]==7;
	wire car1 = CounterX>(cnt) && CounterX<(50+cnt) && CounterY>30 && CounterY<50;
	wire car2 = CounterX>(550-cnt2) && CounterX<(600-cnt2) && CounterY>80 && CounterY<100;
	wire car3 = CounterX>(cnt3) && CounterX<(50+cnt3) && CounterY>140 && CounterY<160;
	wire car4 = CounterX>(550-cnt) && CounterX<(600-cnt) && CounterY>200 && CounterY<220;
	wire car5 = CounterX>(cnt2) && CounterX<(50+cnt2) && CounterY>300 && CounterY<320;
	
	wire life1 = CounterY>=460 && CounterY<=465 && CounterX>=0 && CounterX<=5 && frogs>=1;
	wire life2 = CounterY>=460 && CounterY<=465 && CounterX>=10 && CounterX<=15 && frogs>=2;
	wire life3 = CounterY>=460 && CounterY<=465 && CounterX>=20 && CounterX<=25 && frogs>=3;
	
	wire target = CounterY>=0 && CounterY<=10;
	
	assign hit = frog && (car1 || car2 || car3 || car4 || car5) && (state==ingame);
	assign victory = frog && target;
	
	always @(posedge clk)
	begin
		vga_r <= (car1||car2||car3||car4||car5) & inDisplayArea || target;
		vga_g <= frog & inDisplayArea || life1 || life2 || life3;
		vga_b <= vga_r & inDisplayArea && (~target);
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	reg[3:0] state = newgame;
	
	
	reg temp = 0;
	//reg[1:0] frogs = 2'b11;
	integer frogs = 3;
	// state declaration
   localparam  [3:0]
      newgame = 4'b0001,
      ingame    = 4'b0010,
      newlife = 4'b0100,
      done    = 4'b1000;
		
		assign ack = btnR&&(state==done);
		assign ack2 = btnL;
always @ (posedge clk, posedge reset)
	begin
		if(reset)
			begin
				if(ack2)
					state <= newgame;
				//frogs <= 3;
			end
		else
		begin
			case(state)
				newgame:
					begin
						state<=ingame;
						frogs<=3;
					end
				ingame:
					begin
						if(hit)
							begin
								
								frogs<=frogs-1;
								if(frogs!=1)
									state<=newlife;
								else 
									state<=done;
							end
						if(victory)
							state<=done;
					end
				newlife:
					begin
						
						state<=ingame;
					end
					
				done:
					begin
						if(ack)
							state<=newgame;
					end
			endcase			
		end
	end
	
	//OFL


/*		
	always @ (posedge Clk, posedge reset)
	begin
		if(reset)
			state <= QINIT;
		else
		begin
			case(state)
		
				QINIT:
					begin
					if({U,Z}==2'b10)
						state <= QG1GET;
					end
				QG1GET:
					if(~U)
						state <= QG1;
				QG1:
					if({U,Z}==2'b01)
						state <= QG10GET;
					else if(U)
						state <= QBAD;
				QG10GET:
					if(~Z)
						state <= QG10;
				QG10:
					if({U,Z}==2'b10)
						state <= QG101GET;
					else if(Z)
						state <= QBAD;
				QG101GET:
					if(~U)
						state <= QG101;
				QG101:
					if({U,Z}==2'b10)
						//state <= QG1011GET;
						state <= QG1011GET;
					else if(Z)
						state <= QBAD;
				QG1011GET:
					if(~U)
						state <= QG1011;
				QG1011:
					state <= QOPENING;
				QOPENING:
					if(TO)
						state <= QINIT;
				QBAD:
					if({U,Z}==2'b00)
						state <= QINIT;
			endcase			
		end
	end
	
	//OFL
	assign Unlock = QOPENING;
*/
		
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	/*
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] sstate;
	*/
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (state == done);
	assign LD1 = 0;
	
	assign LD2 = hit;//hit_car1;
	assign LD4 = orig;
	
	assign LD3 = (state == newgame);
	assign LD5 = (state == ingame);	
	assign LD6 = (state == newlife);
	assign LD7 = 0;
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = state;
	assign SSD2 = 4'b1111;
	assign SSD1 = hit;
	//assign SSD0 = position[3:0];
	assign SSD0 = frogs[1:0];
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b1111: SSD_CATHODES = 7'b1111111 ; //Nothing 
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1010: SSD_CATHODES = 7'b0001000 ; //10 or A
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule