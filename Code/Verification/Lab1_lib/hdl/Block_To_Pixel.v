//
// Verilog Module Lab1_lib.Block_To_Pixel
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 13:10:42 11/25/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Block_To_Pixel #(
   parameter Amba_Addr_Depth = 20,
   parameter Amba_Word       = 16,
   parameter Data_Depth      = 8
)
( 
   // Port Declarations
   input   wire                              clk,         //system clock
   input   wire                              rst,         //  Reset active low
   input   wire    [19:0]                    M2,          //M*M number of pixel in a block
   input   wire    [(Data_Depth*72*72)-1:0]  block_in,       //Block (after watermarking)  that sent to Block to Pixel
   input   wire                              block_done,  //Finished watermark insertion of block
   output  reg     [Data_Depth-1:0]          Pixel_Data,  //Modified pixel (Output)
   output  reg                               Ready,       //Block_To_Pixel is ready to recive new block
   output  reg                               new_pixel,   //New pixel indicator
   input   wire                              last_Block,  //State indicator - Control and Registers Image done
   output  reg                               Image_Done   //State indicator (Output)
);


// Internal Declarations

// ### Please start your Verilog code here ### 
always @(posedge Ready) begin: Check_last_block
  if (last_Block)
    Image_Done<= 1;
  else
    Image_Done<= 0;
end

reg [72*72-1:0] i;// index for outputing 1 pixel each time
reg [1:0] state;// 0- nothing/finished, 1- init , 2- start sending, 3- new_pixel=0 clock 

always @(posedge  block_done) begin: init_state
  state <=1;
end

always @(posedge  clk) begin: output_pixel
  if (rst) begin
    Image_Done<= 0;
    state<=0;
    i <= 1;
    new_pixel <=0;
    Ready <= 1;
  end
  else begin
    case (state)
      0:begin //finished
          Ready<=1;// ready for another block
        end
      1:begin //init
          i <= 1;
          new_pixel <=0;
          state<=2;
          Ready <= 0;
        end
      2:begin // we can start sending pixels
          if (i <= M2) begin
            Pixel_Data <= block_in[ ((i*Data_Depth)-1) -: Data_Depth];
            i <= i + 1;
            new_pixel <=1;
            state<= 3;
          end
          else state <=0; //finish sending
        end
      default:begin  //state =3
          new_pixel <=0;
          state<= 2;
        end
      endcase// case
  end
end // always output_pixel

endmodule
