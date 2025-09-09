module item_memory #(
    parameter MAX_ITEMS = 1024,
    parameter ITEM_ADDR_WIDTH = $clog2(MAX_ITEMS)
)(
    input  wire clk,

    // Config interface
    input  wire we,  // Write enable (for config)
    input  wire dispense_valid,  // Dispense signal (runtime update)
    input  wire [ITEM_ADDR_WIDTH-1:0] waddr,  // Common address
    input  wire [7:0] dispensed_item,  // For initial config
    input  wire [7:0] count,
    input  wire [15:0] price,

    output reg [31:0] item_data_out  // Optional output
);

    reg [31:0] mem [0:MAX_ITEMS-1];

    always @(posedge clk) begin
        if (we) begin
            // Config write
            mem[waddr] <= {dispensed_item, count, price};
        end else if (dispense_valid) begin
            // Dispense logic using same address
            reg [31:0] temp;
            temp = mem[waddr];

            temp[31:24] = temp[31:24] + 1;       // Increment dispensed count
            if (temp[23:16] > 0)
                temp[23:16] = temp[23:16] - 1;   // Decrement available count

            mem[waddr] <= temp;
        end

       
        item_data_out <= mem[waddr];
    end

endmodule
