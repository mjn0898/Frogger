`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:07:40 04/10/2018 
// Design Name: 
// Module Name:    counter 
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
module counter(
out     ,  // Output of the counter
enable  ,  // enable for counter
clk     ,  // clock Input
reset      // reset Input
);
//----------Output Ports--------------
    output [7:0] out;
//------------Input Ports--------------
     input enable, clk, reset;
//------------Internal Variables--------
    reg [7:0] out;
//-------------Code Starts Here-------
always @(posedge clk)
if (reset) begin
  out <= 7'b0 ;
end else if (enable) begin
  out <= out + 1;
end


endmodule 
