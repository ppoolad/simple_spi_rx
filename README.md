# AXI Simple RX IP

## Overview

The `axi_simple_rx` module is an AXI-based receiver IP core designed to interface with an AXI Master Bus. It receives data through differential signals and outputs it to the AXI Master Bus Interface.

## Parameters

- `C_M00_AXIS_TDATA_WIDTH` (default: 32): Width of the AXI data bus.
- `C_M00_AXIS_START_COUNT` (default: 32): Start count for the AXI interface.

## Ports

### Input Ports

- `sclk`: Serial clock input.
- `sdata_p`: Positive differential data input.
- `sdata_n`: Negative differential data input.
- `svalid_p`: Positive differential valid signal.
- `svalid_n`: Negative differential valid signal.
- `m00_axis_aclk`: AXI clock input.
- `m00_axis_aresetn`: AXI reset input (active low).
- `m00_axis_tready`: AXI ready signal.

### Output Ports

- `data_o_dbg`: Debug signal for data output.
- `m00_axis_tvalid`: AXI valid signal.
- `m00_axis_tdata`: AXI data output.
- `m00_axis_tstrb`: AXI strobe signal.
- `m00_axis_tlast`: AXI last signal.

## Instantiation Template

```verilog
axi_simple_rx #(
    .C_M00_AXIS_TDATA_WIDTH(32), // Set the parameter value as needed
    .C_M00_AXIS_START_COUNT(32)  // Set the parameter value as needed
) axi_simple_rx_inst (
    .sclk(sclk),                 // Connect to the appropriate signal
    .sdata_p(sdata_p),           // Connect to the appropriate signal
    .sdata_n(sdata_n),           // Connect to the appropriate signal
    .svalid_p(svalid_p),         // Connect to the appropriate signal
    .svalid_n(svalid_n),         // Connect to the appropriate signal
    .data_o_dbg(data_o_dbg),     // Connect to the appropriate signal
    .m00_axis_aclk(m00_axis_aclk), // Connect to the appropriate signal
    .m00_axis_aresetn(m00_axis_aresetn), // Connect to the appropriate signal
    .m00_axis_tvalid(m00_axis_tvalid), // Connect to the appropriate signal
    .m00_axis_tdata(m00_axis_tdata),   // Connect to the appropriate signal
    .m00_axis_tstrb(m00_axis_tstrb),   // Connect to the appropriate signal
    .m00_axis_tlast(m00_axis_tlast),   // Connect to the appropriate signal
    .m00_axis_tready(m00_axis_tready)  // Connect to the appropriate signal
);