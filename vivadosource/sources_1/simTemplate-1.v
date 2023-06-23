`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2018 08:37:20 AM
// Design Name: 
// Module Name: simTemplate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//                
//////////////////////////////////////////////////////////////////////////////////
module simTemplate(
     );
    
     reg CLK=0,RSTBTN; 
     reg [15:0] SWITCHES,LEDS;
     reg [7:0] CATHODES;
     reg [3:0] ANODES;
    OTTER_Wrapper ottr (.CLK(CLK), .RSTBTN(RSTBTN), .SWITCHES(SWITCHES), .LEDS(), .CATHODES(), .ANODES(), .SDA(SDA), .SCL(SCL));
    initial forever  #10  CLK =  ! CLK; 
   
    initial begin
        RSTBTN=1;
        #100
        RSTBTN=0;
        SWITCHES=15'd0;
    end
    
    i2c_slave i2c_slave_inst(.scl(SCL), .sda(SDA));

endmodule
