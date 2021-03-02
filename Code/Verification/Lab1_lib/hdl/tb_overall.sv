//
// Verilog Module Lab1_lib.tb_overall
//
// Created:
//          by - amitnag.UNKNOWN (SHOHAM)
//          at - 17:37:17 12/ 5/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module tb_overall #(
  parameter Amba_Addr_Depth = 20,  //Part of the Amba standard at Moodle site; Range - 20,24,32
   parameter Amba_Word       = 16,  //Part of the Amba standard at Moodle site; Range - 16,24,32
   parameter Data_Depth      = 8);

Interface tb();
Stimulus gen(
    .stim_bus(tb)
    );
Visible_Watermarking dut(
    //.dut_bus(tb)

    .clk(tb.clk),
    .rst(tb.rst),
    .PWRITE(tb.PWRITE),
    .PWDATA(tb.PWDATA),
    .PSEL(tb.PSEL),
    .PENABLE(tb.PENABLE),
    .PADDR(tb.PADDR),
    .new_pixel(tb.new_pixel),
    .Pixel_Data(tb.Pixel_Data),
    .Image_Done(tb.Image_Done)   
    );
Coverage cov(
    .coverage_bus(tb)
    );
Checker check(
    .checker_bus(tb)
    );
GoldModel res_test(
    .gold_bus(tb)
    );

endmodule
