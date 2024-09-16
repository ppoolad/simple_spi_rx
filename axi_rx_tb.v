`timescale 1ns / 1ps

module test_axi_rx;

    // Parameters
    parameter packet_length = 32;

    // Inputs
    reg sclk;
    reg sdata;
    reg svalid;
    reg aclk;
    reg aresetn;
    reg fifo_ready;

    // Outputs
    wire [packet_length-1:0] fifo_data;
    wire fifo_valid;

    reg [packet_length-1:0] gold_data;

    // Instantiate the Unit Under Test (UUT)
    axi_rx #(
        .packet_length(packet_length)
    ) uut (
        .sclk(sclk),
        .sdata(sdata),
        .svalid(svalid),
        .aclk(aclk),
        .aresetn(aresetn),
        .fifo_data(fifo_data),
        .fifo_valid(fifo_valid),
        .fifo_ready(fifo_ready)
    );

    // Clock generation
    initial begin
        sclk = 0;
        #1; //mismatch between sclk and aclk
        forever #5 sclk = ~sclk; // 100 MHz clock
    end

    initial begin
        aclk = 0;
        forever #20 aclk = ~aclk; // 25 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        aresetn = 0;
        sdata = 0;
        svalid = 0;
        fifo_ready = 0;

        // Apply reset
        #20;
        aresetn = 1;

        // Test case 1: Single packet reception
        $display("Test case 1: Single packet reception");
        #20;
        svalid = 1;
        fifo_ready = 1;
        repeat (packet_length) begin
            sdata = $random;
            gold_data = {gold_data[30:0], sdata};
            #10;
        end
        svalid = 0;

        // Wait for FIFO to be valid
        wait (fifo_valid);
        $display("Received packet: %h", fifo_data);
        $display("Gold packet: %h", gold_data);

        if (fifo_data === gold_data) begin
            $display("Test case 1 Part 1 PASSED");
        end else begin
            $display("Test case 1 FAILED");
            $error("Received packet: %h", fifo_data);
        end

        //again
        #20;
        svalid = 1;
        fifo_ready = 1;
        repeat (packet_length) begin
            sdata = $random;
            gold_data = {gold_data[30:0], sdata};
            #10;
        end
        svalid = 0;

        // Wait for FIFO to be valid
        wait (fifo_valid);
        $display("Received packet: %h", fifo_data);
        $display("Gold packet: %h", gold_data);

        if (fifo_data === gold_data) begin
            $display("Test case 1 PASSED");
        end else begin
            $display("Test case 1 FAILED");
            $error("Received packet: %h", fifo_data);
        end

        // Test case 2: Multiple packets reception
        $display("Test case 2: Multiple packets reception");
        #20;
        svalid = 1;
        fifo_ready = 1;
        repeat (packet_length) begin
            sdata = $random;
            gold_data = {gold_data[30:0], sdata};
            #10;
        end
        
        
        $display("Gold packet: %h", gold_data);
        // if (fifo_data != gold_data) begin
        //     $display("Test case 2 FAILED");
        //     $error("Received packet: %h", fifo_data);
        // end

        repeat (packet_length) begin
            sdata = $random;
            gold_data = {gold_data[30:0], sdata};
            #10;
            if(fifo_valid == 1'b1)
                $display("Received packet: %h", fifo_data);
        end
        svalid = 0;

        // Wait for FIFO to be valid
        wait (fifo_valid);
        $display("Received packet: %h", fifo_data);
        $display("Gold packet: %h", gold_data);

        if(fifo_data === gold_data) begin
            $display("Test case 2 PASSED");
        end else begin
            $display("Test case 2 FAILED");
            $error("Received packet: %h", fifo_data);
        end

        // End simulation
        #100;
        $finish;
    end

endmodule