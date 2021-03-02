//
// Verilog Module Lab1_lib.GoldModel
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 18:19:56 12/10/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module GoldModel #(
   parameter Amba_Addr_Depth = 10,  //Part of the Amba standard at Moodle site; Range - 20,24,32
   parameter Amba_Word       = 16,  //Part of the Amba standard at Moodle site; Range - 16,24,32
   parameter Data_Depth      = 8)
( 
   // Port Declarations
   //modport Goldmodel (input Image_Done, Pixel_Data , new_pixel);
   Interface.Goldmodel gold_bus
);

`define NULL 0
// Data Types
integer data_file_0;
integer scan_file_0;
integer data_file_1;
integer i = 1;
real mse = 0;
integer n;
integer Y1,Y2;



string  str0 = "C:/Users/amitnag/Desktop/Lab1/GoldenModel/watermarked_image(result)_";
string  str1 = "C:/Users/amitnag/Desktop/Lab1/GoldenModel/hdl_design_watermarked_image(result)_";

string  val;

reg [Data_Depth-1:0] resultpix [2**(20-1)-1:0];
reg [Data_Depth-1:0] currentpix;
reg [10-1:0] resultsize;
reg [21-1:0] count;
reg          imageD =1;

initial
begin : init_proc

    //------------------------------------------------------------------------------------------
    //// The Golden Model Result Image Pixels file
    val.itoa(i);
    data_file_0 = $fopen($sformatf({str0, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
    end
    if (!$feof(data_file_0)) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultsize);
      n=resultsize;
    end
    for (count=0;count<resultsize*resultsize;count=count+1) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultpix[count]);
    end
    count = 0;
    //// Our Architectural Model Result Image Pixels file (For Saving)
    val.itoa(i);
    data_file_1 = $fopen($sformatf({str1, val, ".txt"}), "w"); // opening file in writing format
    if (data_file_1 == `NULL) begin
      $display("data_file_1 handle was NULL");
      $finish;
    end
    //------------------------------------------------------------------------------------------
    //// Initilization
    mse = 0;
    count = 0;

end

always @(posedge gold_bus.Image_Done) // finished picture
begin : image_indicator
      mse = mse/(n*n);

      $display("iteration Num. %d Finished\n",i);
      $display("iteration Num. %d :: picture size=%d  Mean Squared Error=%f\n",i,n*n,mse);
      count = 0;
      i = i + 1;
      if (i == 11) begin
        $finish;
      end
      if (count==0 && i!=1) begin // each beginning except first time
    //------------------------------------------------------------------------------------------
    //// The Golden Model Result Image Pixels file
    val.itoa(i);
    data_file_0 = $fopen($sformatf({str0, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
    end
    if (!$feof(data_file_0)) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultsize);
      n=resultsize;
    end
    for (count=0;count<resultsize*resultsize;count=count+1) begin
      scan_file_0 = $fscanf(data_file_0, "%d\n", resultpix[count]);
    end
    count = 0;
    //// Our Architectural Model Result Image Pixels file (For Saving)
    val.itoa(i);
    data_file_1 = $fopen($sformatf({str1, val, ".txt"}), "w"); // opening file in writing format
    if (data_file_1 == `NULL) begin
      $display("data_file_1 handle was NULL");
      $finish;
    end
    //------------------------------------------------------------------------------------------
    //// Initilization
    mse = 0;
    count = 0;
  end
end

always @(posedge gold_bus.new_pixel)//check pos or neg
begin : res_proc 
  $fwrite(data_file_1, "%d\n", gold_bus.Pixel_Data);
  Y1= resultpix[count];
  Y2=gold_bus.Pixel_Data;    
 
    mse = mse + (Y2-Y1)*(Y2-Y1);
    count = count + 1; 
  end    
endmodule
