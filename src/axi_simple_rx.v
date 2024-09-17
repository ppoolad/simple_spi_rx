
`timescale 1 ns / 1 ps

	module axi_simple_rx #
	(

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
		input wire sclk,
		input wire sdata_p,
		input wire sdata_n,
		input wire svalid_p,
		input wire svalid_n,

		//debug signal 
		output reg data_o_dbg,
		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
    
	wire data_bit_w, valid_bit_w;
// Instantiation of Axi Bus Interface M00_AXIS
// Instantiation of axi_rx module
	axi_rx #(
		.packet_length(C_M00_AXIS_TDATA_WIDTH) // Set the parameter value as needed
	) axi_rx_inst (
		.sclk(sclk),           // negated to adjust timing
		.sdata(data_bit_w),        
		.svalid(valid_bit_w),    
		.aclk(m00_axis_aclk),         
		.aresetn(m00_axis_aresetn),    
		.fifo_data(m00_axis_tdata), 
		.fifo_valid(m00_axis_tvalid), 
		.fifo_ready(m00_axis_tready) 
	);
	
	assign m00_axis_tstrb = 4'b1111;
	assign m00_axis_tlast = 1'b1;
	// instantiate lvds receiver
    // LVDS receiver

    // LVDS0
    IBUFDS IBUFDS_inst0 (
   .O(data_bit_w),   // 1-bit output: Buffer output
   .I(sdata_p),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
   .IB(sdata_n)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );
  
    // LVDS1
    IBUFDS IBUFDS_inst1 (
   .O(valid_bit_w),   // 1-bit output: Buffer output
   .I(svalid_p),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
   .IB(svalid_n)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );


	// debug sliced data bit
	always @(negedge sclk) begin
		data_o_dbg <= data_bit_w & valid_bit_w;
	end
	// User logic ends

	endmodule
