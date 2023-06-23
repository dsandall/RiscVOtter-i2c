`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Calllenes
//           P. Hummel
//           Dylan Sandall
// 
// Create Date: 01/20/2019 10:36:50 AM
// Design Name: 
// Module Name: OTTER_Wrapper 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.81 - I2C module added
// Additional Comments: tess                
//////////////////////////////////////////////////////////////////////////////////

module OTTER_Wrapper(
    input CLK,
    input RSTBTN,
    input [15:0] SWITCHES,
    output [15:0] LEDS,
    output [7:0] CATHODES,
    output [3:0] ANODES, 
    inout SDA, 
    inout SCL
    );
    // INPUT PORT IDS ////////////////////////////////////////////////////////////
    localparam SWITCHES_AD = 32'h11000000;
           
    // OUTPUT PORT IDS ///////////////////////////////////////////////////////////
    localparam LEDS_AD     = 32'h11080000;
    localparam SSEG_AD     = 32'h110C0000;
    localparam I2C_SLAVE_AD = 32'h11FF00A0;
    localparam I2C_FLAG_AD = 32'h11FF00B0;
    localparam I2C_MOSI_AD = 32'h11FF0000;
    localparam I2C_MISO_AD = 32'h11FF0010;
    
    
    
    // Signals for connecting OTTER_MCU to OTTER_wrapper /////////////////////////
    logic s_reset;
    logic sclk = '0;
    
    
    
    //I2C
    pullup p1(SCL); // pullup scl line
	pullup p2(SDA); // pullup sda line   
	wire clrNM;
	
    // Registers for IOBUS ///////////////////////////////////////////////////////   
    logic [15:0] r_SSEG = '0;
    logic [15:0] r_LEDS = '0;
    logic [7:0] r_I2C_SLAVE = '0;
    logic [7:0] r_I2C_FLAG = '0;
    logic [7:0] r_I2C_MOSI = '0;
    logic [7:0] r_I2C_MISO = '0;

    // Signals for IOBUS /////////////////////////////////////////////////////////
    logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr;
    logic IOBUS_wr;
   

    
    // Clock divider //////////////////////////////
        always_ff @(edge CLK) begin
            sclk <= ~sclk;
        end   
    
    OTTER_MCU MCU(.EXT_RESET(s_reset), .CLK(sclk), 
                  .IOBUS_OUT(IOBUS_out), .IOBUS_IN(IOBUS_in),
                  .IOBUS_ADDR(IOBUS_addr), .IOBUS_WR(IOBUS_wr));

    SevSegDisp SSG_DISP(.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b0),
                        .CATHODES(CATHODES), .ANODES(ANODES));

    debounce_one_shot DB_R(.CLK(sclk), .BTN(RSTBTN), .DB_BTN(s_reset));

    i2c_connect I2Cmodule_inst(.SYS_CLOCK(sclk), .MOSI(r_I2C_MOSI), .SLAVE_ADDR(r_I2C_SLAVE[6:0]), .RW(r_I2C_FLAG[0]), .NEWMSG(r_I2C_FLAG[1]),
                    .MISO(r_I2C_MISO), .clrNM(clrNM), 
                    .SDA(SDA), .SCL(SCL));
                    
 // Connect board peripherals (Memory Mapped IO devices) to IOBUS /////////////
    // Connect LEDS register to port /////////////////////////////////////////////
    assign LEDS = r_LEDS;

    // ---- Inputs
    always_comb begin
        IOBUS_in = 32'b0;
        case (IOBUS_addr)
            SWITCHES_AD: IOBUS_in[15:0] = SWITCHES;
            I2C_SLAVE_AD: IOBUS_in[7:0] = r_I2C_SLAVE;
            I2C_FLAG_AD: IOBUS_in[7:0] = r_I2C_FLAG;
            I2C_MISO_AD: IOBUS_in[7:0] = r_I2C_MISO;
        endcase
    end
    // ---- Outputs
    always_ff @(posedge sclk) begin
        if (IOBUS_wr) begin
            case (IOBUS_addr)
                LEDS_AD: r_LEDS <= IOBUS_out[15:0];
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
                I2C_SLAVE_AD: r_I2C_SLAVE <=  IOBUS_out[7:0];
                I2C_FLAG_AD: r_I2C_FLAG <=  IOBUS_out[7:0];
                I2C_MOSI_AD: r_I2C_MOSI <=  IOBUS_out[7:0];
            endcase
        end
        else if (clrNM) begin
            r_I2C_FLAG[1] <= 1'b0;
        end
    end
 
endmodule
