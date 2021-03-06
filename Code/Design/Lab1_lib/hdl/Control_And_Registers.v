//
// Verilog Module Lab1_lib.Control_And_Registers
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 16:58:10 11/20/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Control_And_Registers #(
   // synopsys template
   parameter Amba_Addr_Depth = 20,  //Part of the Amba standard at Moodle site; Range - 20,24,32
   parameter Amba_Word       = 16,  //Part of the Amba standard at Moodle site; Range - 16,24,32
   parameter Data_Depth      = 8    //Bit depth of the pixel; Range - 8,16
)
( 
   // Port Declarations
   input   wire                              clk,         // system clock
   input   wire                              rst,         //  Reset active low
   input   wire                              ena_in,      //  Reset active low
   // Port Declarations
   input   wire    [Amba_Addr_Depth-1:0]     Address,     // APB Address Bus
   input   wire    [Amba_Word-1:0]           data_in,     // APB Read Data Bus
   output  reg                               ena_out,     // when a block is ready
   output  reg                               Image_Done,  //State indicator (Output)
   input   wire                              Block_Done,  // when block is done
   output  reg     [(10*9)-1:0]              params,      //[9:0]//9 params size of 9 bits
   output  reg     [(Data_Depth*72*72)-1:0]  Im_block,    //[(72*72)-1:0],  // Max size of block is 72*72 pixels and size of pixel is DATA_DEPTH
   output  reg     [(Data_Depth*72*72)-1:0]  W_block      //[(72*72)-1:0],  // Max size of block is 72*72 pixels and size of pixel is DATA_DEPTH
);

// Internal Declarations




// ### Please start your Verilog code here ### 
//-------------------------------------------------------
//-------------------registers -----------------------
//-------------------------------------------------------

reg [Amba_Word-1:0] registers [2**(Amba_Addr_Depth-1):0];
reg [19:0] M2 ;
reg [19:0] N2 ;
 
always @(posedge  clk) begin: reg_proc
  if (rst) begin
    registers[0] <=0;
  end
  if (ena_in) begin
    registers[Address] <= data_in;
    if (Address == 4) 
      M2 <= data_in*data_in;
    if (Address == 2) 
      N2 <= data_in*data_in;
  end
end

//-------------------------------------------------------

//-------------------------------------------------------
//----------------------Block Logic ---------------------
//-------------------------------------------------------

reg [18:0] block_i; // max 720*720, number of pixels
reg [12:0] pixel_i;  // max pixels in block is 72*72 = 5184
reg [2:0] param_i; // we have 7 params
reg [1:0] state; // 0 - Im_block, 1 - W_block , 2 - params

always @(posedge  clk) begin: block_filler
  if (rst) begin
    ena_out<=0;
    block_i <= 0;
    pixel_i <=0;
    param_i <= 0;
    state <= 0;
    Image_Done <= 0;
  end
  if (registers[0][0] && Block_Done) begin //start_bit == 1 and block_done
      ena_out<=0;
      case (state)
        0: begin//Im_block
          if(pixel_i >= M2) begin//if pixel index >= M^2 finished Im_block
            pixel_i <=0;
            state <= 1;
          end
          else begin
            Im_block[(pixel_i+1)*Data_Depth-1 -: Data_Depth]<= registers[pixel_i + 10 + block_i*M2][Data_Depth-1:0];
            pixel_i <= pixel_i + 1;           
          end
        end// case 0
        
        1: begin//W_block
          if(pixel_i >= M2) begin//if pixel index >= M^2 finished Im_block
              pixel_i <=0;
              state <= 2;
          end
          else begin
              W_block[(pixel_i+1)*Data_Depth-1 -: Data_Depth]<= registers[pixel_i + 10 + N2 + block_i*M2][Data_Depth-1:0];
              pixel_i <= pixel_i + 1;           
          end
        end// case 1
        
        default: begin// state = 2                     
          if(param_i >= 7) begin// block filler finished
              Image_Done <= 0;
              param_i <=0;
              state <= 0;             
              ena_out <= 1;
              block_i <= block_i + 1;             
              if (block_i+1 >= (N2)/(M2)) begin // end of image
                Image_Done <= 1;
                block_i <= 0;
              end
          end
          else begin
            case (param_i)
              0:   
                params[9:0] <= registers[1]; //WhitePixel 7:0
              1:begin
                  params[29:10] <= M2; //M^2  19:0
                  params[39:30] <= registers[4];// M
                 end
              2:   
                params[49:40] <= registers[5]; //EdgeThreshold 7:0
              3:   
                params[59:50] <= registers[6]; //Amin 6:0
              4:   
                params[69:60] <= registers[7]; //Amax 6:0
              5:   
                params[79:70] <= registers[8]; //Bmin 5:0
              default: // pixel_i = 7
                params[89:80] <= registers[9]; //Bmax 5:0
            endcase
            param_i <= param_i + 1;
          end// else end
        end
      endcase 
    end
end

endmodule
