//
// Verilog Module Lab1_lib.Equation_Implementation
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 12:33:49 11/23/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Equation_Implementation #(
   // synopsys template
   parameter Amba_Addr_Depth = 20,  //Part of the Amba standard at Moodle site; Range - 20,24,32
   parameter Amba_Word       = 16,  //Part of the Amba standard at Moodle site; Range - 16,24,32
   parameter Data_Depth      = 8    //Bit depth of the pixel; Range - 8,16
)
( 
   // Port Declarations
   input   wire    [(Data_Depth*72*72)-1:0]  Im_block,    //[(72*72)-1:0],  // Max size of block is 72*72 pixels and size of pixel is DATA_DEPTH
   input   wire                              Ready,       //Block_To_Pixel is ready to recive new block
   input   wire    [(Data_Depth*72*72)-1:0]  W_block,     //[(72*72)-1:0],  // Max size of block is 72*72 pixels and size of pixel is DATA_DEPTH
   input   wire                              clk,         //system clock
   input   wire                              ena_in,      //Enable
   input   wire    [(10*9)-1:0]              params,      //[9:0]//9 params size of 9 bits
   input   wire                              rst,         //Reset active low
   output  reg                               block_done,  //Finished watermark insertion of block
   output  reg     [(Data_Depth*72*72)-1:0]  block_out,   //[(72*72)-1:0],  // Max size of block is 72*72 pixels and size of pixel is DATA_DEPTH
   output  reg     [19:0]                    M2           //M*M number of pixel in a block
);


// Internal Declarations




// ### Please start your Verilog code here ### 


//-----------------------sum_block-------------------------------------------------------------
reg [31:0] sum3,sum4,sum5; // each sumX is the double Sigma from each (X) equation // 510*72*72*data_depth
reg sums_done; //sums_calc block is finished
reg [19:0] i; //index of block's pixels
reg [19:0] endOfRow; // indicator for end of row in the block, for eq.5

always @(posedge  clk) begin: sums_calc
  reg [Data_Depth-1:0] pixel,pixel2,pixel3;
  if (rst | block_done) begin
    block_done <= 1;
    sums_done<=0;
    sum3<=0;
    sum4<=0;
    sum5<=0;
    i<=1;
    endOfRow<=params[39:30]; //M
  end
  else begin
      if (i <=  params[29:10]) begin // still adding -M2   
        pixel =Im_block[i*Data_Depth-1 -: Data_Depth];
        
        //-------------sum3---------------------
        sum3 <= sum3 + pixel; // 1<=i<=M^2
        
        //-------------sum4---------------------
           // doing ABS in eq.4
        sum4 <=  (pixel< ((params[9:0]+1)/2))? sum4 +(((params[9:0]+1)/2)- pixel):sum4 +(pixel - ((params[9:0]+1)/2));
          
        //-------------sum5---------------------
        pixel2 = (i == endOfRow)? 0:Im_block[(i+1)*Data_Depth-1 -: Data_Depth]; //  check for i+1 out of bounds
        //pixel3 = (i+M > M^2) -- last row 
        pixel3 = (i+params[39:30]>params[29:10])? 0:Im_block[(i+params[39:30])*Data_Depth-1 -: Data_Depth]; //  check for i+M out of bounds
           
        if (i == endOfRow) endOfRow<=endOfRow+params[39:30]; // increasing the end of Row
        
        sum5 <= ((pixel< pixel2) & (pixel< pixel3)) ? sum5 + pixel2 - pixel + pixel3 - pixel: // doing ABS in eq.5
                ((pixel< pixel2) & (pixel> pixel3)) ? sum5 + pixel2 - pixel3:
                ((pixel> pixel2) & (pixel< pixel3)) ? sum5 - pixel2 + pixel3:
                                                      sum5 - pixel2 + pixel - pixel3 + pixel;
  
        i <= i +1;
      end
      else begin // finish claculating the sums
        sums_done <= 1;
      end         
    
  end
end



//--------------------------multply by constants (finish eq.3,4,5)-------------
reg eq345_done;//equation 3,4,5 are finished
reg [9:0] Sigma;// sigma between 0-1000 milli (0-255/256)
reg [9:0] Mu; // mu between 0-1000 milli (0-1)
reg [8:0] G;// G between 0-510 milli

always @(posedge  clk) begin: eq345_calc
  if (rst | block_done) begin
   eq345_done<= 0;
  end
  else begin 
    if (sums_done) begin
      Mu <= sum3*1000/(params[29:10]*(params[9:0]+1));
      Sigma <= sum4*2*1000/(params[29:10]*(params[9:0]+1));
      G <= sum5/params[29:10];
      
      eq345_done<= 1;
    end
  end
end



//--------------------------eq1,2 (calculates eq.1,2)-------------
reg [9:0] alpha; // 0-1000 in milli
reg [19:0] beta; // 0-1000 in milli
reg eq12_done; //equation 1,2 are finished
wire [9:0] pow;
Power2 pow2(.Mu(Mu),.pow(pow)); // return answer for 2^(-((Mu-0.5)^2)), in milli!!

always @(posedge  clk) begin: eq12_calc
  if (rst | block_done) begin
   eq12_done <= 0;
  end
  else begin 
    if (eq345_done) begin
      //alpha[m] <= Amin[m] + (Amax-Amin)[m]*1000)/Sigma[m])*pow[m]*1000
      alpha <= params[59:50]*10 + (((params[69:60]-params[59:50])*10)*1000/Sigma)*pow/1000;//(1000*1000/1000)*1000/1000
            //beta[m] <=  Bmin[m] +  (Bmax - Bmin)[m]*Sigma[m]*(1-pow)[m]
      beta <=  params[79:70]*10 +  ((params[89:80] - params[79:70]))*Sigma*(1000-pow)/100000;// 100*1000*1000/100000
      eq12_done<= 1;
      
    end
  end
end

//--------------------------result always-------------
reg [19:0] i_res;//index of block's pixels for result

always @(posedge  clk) begin: watermarking_result
  integer calc_result;// result of the pixel output, uses for clipping it down to 255
  if (rst | block_done) begin
   i_res <=1;
  end
  else begin 
    if (eq12_done & Ready) begin// i want to check if Block_to_Pixel is Ready
      if (i_res <=  params[29:10]) begin // finished
      // check if G> Bthr
      // if true-> block_out[pixel_i] = Amax*Im_block[pixel_i]  + Bmin*W_block[pixel_i]
      // else-> block_out[pixel_i] = alpha*Im_block[pixel_i]  + beta*W_block[pixel_i] 
      calc_result = (G>params[49:40])?      
             (params[69:60]*Im_block[i_res*Data_Depth-1 -: Data_Depth] +params[79:70]*W_block[i_res*Data_Depth-1 -: Data_Depth])/100:
             (alpha*Im_block[i_res*Data_Depth-1 -: Data_Depth] + beta*W_block[i_res*Data_Depth-1 -: Data_Depth])/1000;            
      i_res <= i_res +1;
      block_out[i_res*Data_Depth-1 -: Data_Depth] <= (calc_result>255)?255:calc_result;
      end
      else begin       
        block_done <= 1;
        i_res <=1;
      end
        
    end
  end
end

always @(posedge clk) begin: M2_proc
     M2 <= params[29:10];
end

always @(posedge  ena_in) begin: block_done_always
   block_done <=0;// Equation_Implementation can start calculating
end

endmodule

/*      
  parametrs map:
  params[9:0]   <= registers[1]; //WhitePixel 7:0
  params[29:10] <= M2; //M^2  19:0
  params[39:30] <= registers[4];// M
  params[49:40] <= registers[5]; //EdgeThreshold 7:0
  params[59:50] <= registers[6]; //Amin 6:0
  params[69:60] <= registers[7]; //Amax 6:0
  params[79:70] <= registers[8]; //Bmin 5:0
  params[89:80] <= registers[9]; //Bmax 5:0
*/