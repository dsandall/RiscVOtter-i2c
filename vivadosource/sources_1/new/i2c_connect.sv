`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2022 05:28:59 PM
// Design Name: 
// Module Name: i2c_connect
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
module i2c_connect(
    input SYS_CLOCK, 
    input [7:0] MOSI,
    input [6:0] SLAVE_ADDR,
    input RW,
    input NEWMSG,
    
    output [7:0] MISO, 
    output reg clrNM =0, //flag for clearing the NEWMSG flag - kinda jank, but functional
    
    inout SDA,
    inout SCL
    );
    
	//Parameters
    //localparam rst = 0;
	localparam [7:0] reg_addr = 0; //always 0? - working theory
    localparam [15:0] divider = 16'h007D; //(should make the I2C clock frequency = 99.2 KHz)
    
    //inits
	reg enable = 0;
	reg [2:0] state = 0;
    wire busy;
    
    //state machine (sets control lines for master module)
    always@ (posedge SYS_CLOCK)begin
        unique case (state)
            0:begin //new msg?
                if (NEWMSG && ~busy) begin
                    state <= 1;
                    enable <= 1;
                end
            end
            
            1:begin //write accepted?
                if (busy) begin
                    state <= 2;
                    enable <= 0;
                end
            end
            
            2:begin //write complete?
                if (~busy) begin
                    state <= 3;
                    clrNM <= 1;
                end
            end
            
            3:begin //flag cleared?
                if (~NEWMSG) begin
                    state <= 0;
                    clrNM <= 0;
                end
            end
        endcase
    end
    
    i2c_master #(.DATA_WIDTH(8),.REG_WIDTH(8),.ADDR_WIDTH(7)) 
        i2c_master_inst(
            .i_clk(SYS_CLOCK),
            .i_rst(1'b0),
            .i_enable(enable),
            .i_rw(RW),
            .i_mosi_data(MOSI),
            .i_reg_addr(reg_addr),
            .i_device_addr(SLAVE_ADDR),
            .i_divider(divider),
            .o_miso_data(MISO),
            .o_busy(busy),
            .io_sda(SDA),
            .io_scl(SCL)
    );

endmodule
