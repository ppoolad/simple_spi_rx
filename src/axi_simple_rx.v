
`timescale 1 ns / 1 ps

	module axi_simple_rx #
	(

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32,

		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		input wire sclk,
		input wire sdata_p,
		input wire sdata_n,
		input wire svalid_p,
		input wire svalid_n,

		//debug signal 
		output wire data_o_dbg,

		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

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
	wire [C_S00_AXI_DATA_WIDTH-1:0] control_reg;
// Instantiation of Axi Bus Interface M00_AXIS
// Instantiation of axi_rx module

// Instantiation of Axi Bus Interface S00_AXI
	axi_rx_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_rx_S00_AXI_inst (
		.control_reg(control_reg),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);	
	

	axi_rx #(
		.packet_length(C_M00_AXIS_TDATA_WIDTH) // Set the parameter value as needed
	) axi_rx_inst (
		.sclk(sclk),           // negated to adjust timing
		.sdata(data_bit_w),        
		.svalid(valid_bit_w),    
		.aclk(m00_axis_aclk),         
		.aresetn(m00_axis_aresetn),  
		.enable(control_reg[0]),  
		.fifo_data(m00_axis_tdata), 
		.fifo_valid(m00_axis_tvalid), 
		.tlast(m00_axis_tlast),
		.fifo_ready(m00_axis_tready),
		.dbg_out(data_o_dbg)
	);
	
	assign m00_axis_tstrb = 4'b1111;
	//assign m00_axis_tlast = 1'b0;
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


	endmodule
