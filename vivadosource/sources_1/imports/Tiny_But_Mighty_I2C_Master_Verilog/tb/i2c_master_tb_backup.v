`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       www.circuitden.com
// Engineers:      Artin Isagholian
//                 Dylan Sandall
// 
// Create Date:    15:43:35 10/22/2020 
// Design Name: 
// Module Name:    i2c_master_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: Changes for RISC-V Otter
// Revision 0.02 - Initial Changes from .01 by Artin Isagholian
// Additional Comments: From https://www.circuitden.com/blog/21
//
//////////////////////////////////////////////////////////////////////////////////
module i2c_master_tb(

    );
    //Generates Clock (due for replacement)
    real clockDelay50 = ((1/ (50e6))/16)*(1e9);  //clock period == 5/4ns  
    reg main_clk = 0;	 
	always begin
	  #clockDelay50;
	  main_clk = ~main_clk;
	end

    //i2c lines
    wire scl; 
    wire sda;
	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line
	
	//remaining master inputs
    reg rst = 1;
	reg enable = 0;
	reg rw = 0;
	reg [7:0] mosi = 0;
	reg [7:0] reg_addr = 0;
    reg [6:0] device_addr = 7'b001_0001;       
    reg [15:0] divider = 16'h0003;
    //and master outputs
    wire [7:0] miso;
    wire       busy;

	i2c_master #(.DATA_WIDTH(8),.REG_WIDTH(8),.ADDR_WIDTH(7)) 
        i2c_master_inst(
            .i_clk(main_clk),
            .i_rst(rst),
            .i_enable(enable),
            .i_rw(rw),
            .i_mosi_data(mosi),
            .i_reg_addr(reg_addr),
            .i_device_addr(device_addr),
            .i_divider(divider),
            .o_miso_data(miso),
            .o_busy(busy),
            .io_sda(sda),
            .io_scl(scl)
    );
	 
    i2c_slave i2c_slave_model_inst(
        .scl(scl),
        .sda(sda)
    );
		

    reg  [7:0] read_data = 0;
    wire [7:0] data_to_write = 8'hDC;
    reg  [7:0] proc_cntr = 0;	 

	always@(posedge main_clk)begin
        unique case (proc_cntr) inside
            //enable reset
            0: begin
                rst <= 1;
                proc_cntr <= proc_cntr + 1;
               end
               
            //disable reset
            1: begin
                rst <= 0;
                proc_cntr <= proc_cntr + 1;
               end
               
            //set input and control values
            2: begin
                rw <= 0; //write operation
                reg_addr <= 8'h00; //writing to slave register 0
                mosi <= data_to_write; //data to be written
                device_addr = 7'b001_0001; //slave address
                divider = 16'hFFFF; //divider value for i2c serial clock
                proc_cntr <= proc_cntr + 1;
               end
               
            //verify master not busy, stall until then
            3: begin
                //if master is not busy set enable high
                if(busy == 0)begin
                    enable <= 1;
                    $display("Enabled write");
                    proc_cntr <= proc_cntr + 1;
                end
               end
               
            //once master has recieved signals (is busy) disable "enable"
            4: begin
                //once busy set enable low
                if(busy == 1)begin
                    enable <= 0;
                    proc_cntr <= proc_cntr + 1;
                end
               end
                               
            //as soon as busy is low again an operation has been completed
            5: begin
                if(busy == 0) begin
                    proc_cntr <= 20;
                    $display("Master done writing");
                end
               end
               
            /*waiting... for no reason?   
            [6:19]: begin
                proc_cntr <= proc_cntr + 1;
               end
            */
             
            //set read operation for master 
            20: begin
                rw <= 1; //read operation
                reg_addr <= 8'h00; //read slave register 0
                device_addr = 7'b001_0001; //slave address
                divider = 16'hFFFF; //divider value for i2c serial clock
                proc_cntr <= proc_cntr + 1;
               end
               
            //enable when master is ready
            21: begin
                if(busy == 0)begin
                    enable <= 1;
                    $display("Enabled read");
                    proc_cntr <= proc_cntr + 1;
                end
               end
               
            //wait for master received confirmation               
            22: begin
                if(busy == 1)begin
                    enable <= 0;
                    proc_cntr <= proc_cntr + 1;
                end
               end
              
            //master is done reading
            23: begin
                if(busy == 0)begin
                    read_data <= miso; //save data for check
                    proc_cntr <= proc_cntr + 1;
                    $display("Master done reading");
                end
               end
               
            //check data from slave
            24: begin
                if(read_data == data_to_write) $display("Read back correct data!");
                else $display("Read back incorrect data!");
                $stop;
               end
        endcase 
	end
endmodule
