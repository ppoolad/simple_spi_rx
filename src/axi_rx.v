/**
 * @module axi_rx
 * @brief recieves spi-like data from ASIC and sends it to the fifo
 * 
 * @inputs
 * - sclk: serial clock
 * - sdata: data signal
 * - svalid: valid signal
 * - aclk:  axi busclock signal
 * - aresetn: active low reset signal
 * - fifo_ready: ready signal from the fifo
 *
 * @outputs
 * - fifo_data: paralellized data.
 * - fifo_valid: shows data is valid.
 * 
 * @notes
 * - I assumed sclk and aclk are timed together.
 * 
 * @author Pooya Poolad
 * @date 2024-09-06
 */

module axi_rx #(
    parameter packet_length = 32 //length of each transaction
)
(
    input wire sclk,
    input wire sdata,
    input wire svalid,
    input wire aclk,
    input wire aresetn,
    output reg [packet_length-1:0] fifo_data,
    output reg fifo_valid,
    input wire fifo_ready,
    
    output wire dbg_out
);

    reg [5:0] bit_count;
    reg [packet_length:0] shift_reg;
    reg [packet_length-1:0] payload;
    reg [packet_length-1:0] fifo_data_r0, fifo_data_r1;
    reg packet_ready;
    reg rx_ack;
    reg fifo_valid_r0, fifo_valid_r1;
    reg rx_start, rx_done;
    // receive data with sclk
    always @(negedge sclk or negedge aresetn) begin
        // reset the shift register and bit count
        if (!aresetn) begin 
            bit_count <= 6'd0;
            shift_reg <= {packet_length{1'b0}};
            packet_ready <= 1'b0;
            payload <= {(packet_length-1){1'b0}};
            rx_start <= 0;
            rx_done <= 0;
        end else begin
            if (svalid) begin // if valid data is received
                if(!rx_start) 
                    shift_reg[packet_length-1:1] <= 0;
                rx_start <= 1;
                rx_done <= 0;
                shift_reg <= {shift_reg[packet_length-2:0], sdata}; // shift in the data
                bit_count <= bit_count + 1; // increment the bit count
                if (bit_count == (packet_length-1)) begin // if the bit count is equal to the packet length
                    rx_start <= 0;
                    shift_reg[packet_length-1:1] <= 0;
                    packet_ready <= 1'b1; // set the packet ready flag
                    payload <= {shift_reg[packet_length-2:0], sdata}; // set the payload
                    bit_count <= 6'd0; //reset bit count
                end
            end else if(rx_start) begin
                rx_start <= 0;
                rx_done <= 1;
                payload <= {shift_reg[packet_length-2:0], sdata};
                packet_ready <= 1'b1;
                bit_count <= 6'd0; //reset bit count
            end
            
            // if the fifo is ready, send the data and reset the packet ready flag
            if (rx_ack) begin
                packet_ready <= 1'b0;
            end
        end
    end
    
    assign dbg_out = shift_reg[packet_length-2:0];

    // send data to the fifo
    always @(posedge aclk or negedge aresetn) begin
        // reset the fifo data and valid signals
        if (!aresetn) begin
            fifo_data <= 32'd0;
            fifo_valid <= 1'b0;
            fifo_data_r0 <= 32'd0;
            fifo_valid_r0 <= 1'b0;
            fifo_data_r1 <= 32'd0;
            fifo_valid_r1 <= 1'b0;
            rx_ack <= 1'b0;
        
        // if the fifo is ready, send the data
        end else begin 
            // if the packet is ready, read the data into retiming registers and acknowledge the reception
            if (packet_ready) begin
                fifo_data_r0 <= payload;
                fifo_valid_r0 <= 1'b1;
                rx_ack <= 1'b1;
            end else begin
                fifo_valid_r0 <= 1'b0;
            end
            
            // retiming registers
            fifo_data_r1 <= fifo_data_r0;
            fifo_valid_r1 <= fifo_valid_r0;
            
            // send the data to the fifo if the fifo is ready
            if (fifo_ready) begin
                fifo_data <= fifo_data_r1;
                fifo_valid <= fifo_valid_r1;
            end

            // keep rx_ack only for one cycle
            if (rx_ack) begin
                rx_ack <= 1'b0;
            end
        end
    end

endmodule

