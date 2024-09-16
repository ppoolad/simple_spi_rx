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
    input wire fifo_ready
);

    reg [5:0] bit_count;
    reg [packet_length:0] shift_reg;
    reg [packet_length-1:0] fifo_data_r0, fifo_data_r1;
    reg packet_ready;
    reg rx_ack;
    reg fifo_valid_r0, fifo_valid_r1;

    // always @(posedge sclk or negedge aresetn) begin
    //     if (!aresetn) begin
    //         bit_count <= 5'd0;
    //         shift_reg <= 32'd0;
    //         packet_ready <= 1'b0;
    //     end else if (svalid) begin
    //         if (bit_count <= (packet_length-1)) begin
    //         shift_reg <= {shift_reg[31:0], sdata};
    //         bit_count <= bit_count + 1;
    //         end
    //     end else begin
    //         if (bit_count == (packet_length)) begin
    //             if (rx_ack == 1'b0) begin
    //                 packet_ready <= 1'b1;
    //             end else begin
    //                 packet_ready <= 1'b0;
    //                 bit_count <= 5'd0;
    //                 shift_reg <= 32'd0;
    //             end         
    //         end else begin
    //             packet_ready <= 1'b0;
    //             bit_count <= 6'd0;
    //             shift_reg <= 32'd0;
    //         end
    //     end
    // end

    always @(posedge sclk or negedge aresetn) begin
        if (!aresetn) begin
            bit_count <= 6'd0;
            shift_reg <= {packet_length{1'b0}};
            packet_ready <= 1'b0;
        end else if (svalid && !packet_ready) begin
            shift_reg <= {shift_reg[packet_length-2:0], sdata};
            bit_count <= bit_count + 1;
            if (bit_count == (packet_length-1)) begin
                packet_ready <= 1'b1;
                bit_count <= 6'd0; //reset bit count
            end
        end else if (rx_ack) begin
            bit_count <= 6'd0;
            shift_reg <= {packet_length{1'b0}};
            packet_ready <= 1'b0;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            fifo_data <= 32'd0;
            fifo_valid <= 1'b0;
            fifo_data_r0 <= 32'd0;
            fifo_valid_r0 <= 1'b0;
            fifo_data_r1 <= 32'd0;
            fifo_valid_r1 <= 1'b0;
            rx_ack <= 1'b0;
        end else begin 
            if (packet_ready) begin
                fifo_data_r0 <= shift_reg[packet_length-1:0];
                fifo_valid_r0 <= 1'b1;
                rx_ack <= 1'b1;
            end else begin
                fifo_valid_r0 <= 1'b0;
            end
            
            fifo_data_r1 <= fifo_data_r0;
            fifo_valid_r1 <= fifo_valid_r0;
            
            if (fifo_ready) begin
                fifo_data <= fifo_data_r1;
                fifo_valid <= fifo_valid_r1;
            end

            if (rx_ack) begin
                rx_ack <= 1'b0;
            end
        end
    end

endmodule

