//
// Verilog interface Lab1_lib.Interface
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 11:40:56 12/ 5/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
interface Interface #(
  parameter Amba_Addr_Depth = 10,  //Part of the Amba standard at Moodle site; Range - 20,24,32
   parameter Amba_Word       = 16,  //Part of the Amba standard at Moodle site; Range - 16,24,32
   parameter Data_Depth      = 8)();

//signals declaration

logic    [Amba_Addr_Depth-1:0]  PADDR;       // APB Address Bus
logic                           PENABLE;     // APB Bus Enable/clk
logic                           PSEL;        // APB Bus Select
logic    [Amba_Word-1:0]        PWDATA;      // APB Write Data Bus
logic                           PWRITE;      // APB Bus Write
logic                           clk;         //system clock
logic                           rst;         //  Reset active low

logic                            Image_Done;  //State indicator (Output)
logic     [Data_Depth-1:0]       Pixel_Data;  //Modified pixel (Output)
logic                            new_pixel;    //New pixel indicator

//modports declaration
modport Stimulus (output clk, rst, PADDR, PENABLE, PSEL,PWDATA, PWRITE,Image_Done);
modport Watermark (input clk, rst, PADDR, PENABLE, PSEL,PWDATA, PWRITE, output Image_Done,Pixel_Data,new_pixel);
modport Checker_Coverager (input clk, rst, PADDR, PENABLE, PSEL,PWDATA, PWRITE,Image_Done,Pixel_Data,new_pixel);
modport Goldmodel (input Image_Done, Pixel_Data , new_pixel);


// ### Please start your Verilog code here ### 
endinterface
