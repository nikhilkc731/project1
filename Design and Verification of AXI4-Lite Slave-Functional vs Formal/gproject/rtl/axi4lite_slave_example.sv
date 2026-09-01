// =============================================================================
// FILE        : axi4lite_slave_example.sv
// PROJECT     : AXI4-Lite UVM VIP  – DUT (unchanged from specification)
// DESCRIPTION : 4 x 32-bit read/write register file AXI4-Lite slave.
// =============================================================================

`default_nettype none

module axi4lite_slave_example #(
    parameter C_AXI_DATA_WIDTH = 32,
    parameter C_AXI_ADDR_WIDTH = 4
) (
    input  wire                                 S_AXI_ACLK,
    input  wire                                 S_AXI_ARESETN,

    input  wire [C_AXI_ADDR_WIDTH-1:0]          S_AXI_AWADDR,
    input  wire [2:0]                           S_AXI_AWPROT,
    input  wire                                 S_AXI_AWVALID,
    output reg                                  S_AXI_AWREADY,

    input  wire [C_AXI_DATA_WIDTH-1:0]          S_AXI_WDATA,
    input  wire [C_AXI_DATA_WIDTH/8-1:0]        S_AXI_WSTRB,
    input  wire                                 S_AXI_WVALID,
    output reg                                  S_AXI_WREADY,

    output reg  [1:0]                           S_AXI_BRESP,
    output reg                                  S_AXI_BVALID,
    input  wire                                 S_AXI_BREADY,

    input  wire [C_AXI_ADDR_WIDTH-1:0]          S_AXI_ARADDR,
    input  wire [2:0]                           S_AXI_ARPROT,
    input  wire                                 S_AXI_ARVALID,
    output reg                                  S_AXI_ARREADY,

    output reg  [C_AXI_DATA_WIDTH-1:0]          S_AXI_RDATA,
    output reg  [1:0]                           S_AXI_RRESP,
    output reg                                  S_AXI_RVALID,
    input  wire                                 S_AXI_RREADY
);

    localparam NUM_REGS   = 4;
    localparam ADDR_LSB   = $clog2(C_AXI_DATA_WIDTH / 8);
    localparam REG_BITS   = $clog2(NUM_REGS);

    reg [C_AXI_DATA_WIDTH-1:0] regs [0:NUM_REGS-1];

    reg                                 aw_pending;
    reg [C_AXI_ADDR_WIDTH-1:0]          aw_addr_latch;
    reg                                 w_pending;
    reg [C_AXI_DATA_WIDTH-1:0]          w_data_latch;
    reg [C_AXI_DATA_WIDTH/8-1:0]        w_strb_latch;

    integer i;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_AWREADY <= 1'b0;
            aw_pending    <= 1'b0;
            aw_addr_latch <= {C_AXI_ADDR_WIDTH{1'b0}};
        end else begin
            if (S_AXI_AWVALID && !S_AXI_AWREADY && !aw_pending) begin
                S_AXI_AWREADY <= 1'b1;
                aw_addr_latch <= S_AXI_AWADDR;
                aw_pending    <= 1'b1;
            end else begin
                S_AXI_AWREADY <= 1'b0;
            end
            if (S_AXI_BVALID && S_AXI_BREADY)
                aw_pending <= 1'b0;
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_WREADY <= 1'b0;
            w_pending    <= 1'b0;
            w_data_latch <= {C_AXI_DATA_WIDTH{1'b0}};
            w_strb_latch <= {(C_AXI_DATA_WIDTH/8){1'b0}};
        end else begin
            if (S_AXI_WVALID && !S_AXI_WREADY && !w_pending) begin
                S_AXI_WREADY <= 1'b1;
                w_data_latch <= S_AXI_WDATA;
                w_strb_latch <= S_AXI_WSTRB;
                w_pending    <= 1'b1;
            end else begin
                S_AXI_WREADY <= 1'b0;
            end
            if (S_AXI_BVALID && S_AXI_BREADY)
                w_pending <= 1'b0;
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_BVALID <= 1'b0;
            S_AXI_BRESP  <= 2'b00;
            for (i = 0; i < NUM_REGS; i = i + 1)
                regs[i] <= {C_AXI_DATA_WIDTH{1'b0}};
        end else begin
            if (S_AXI_BVALID && S_AXI_BREADY)
                S_AXI_BVALID <= 1'b0;

            if (aw_pending && w_pending && !S_AXI_BVALID) begin
                S_AXI_BVALID <= 1'b1;
                S_AXI_BRESP  <= 2'b00;
                for (i = 0; i < C_AXI_DATA_WIDTH/8; i = i + 1) begin
                    if (w_strb_latch[i])
                        regs[aw_addr_latch[ADDR_LSB +: REG_BITS]][i*8 +: 8]
                            <= w_data_latch[i*8 +: 8];
                end
            end
        end
    end

    reg                                 ar_pending;
    reg [C_AXI_ADDR_WIDTH-1:0]          ar_addr_latch;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_ARREADY <= 1'b0;
            ar_pending    <= 1'b0;
            ar_addr_latch <= {C_AXI_ADDR_WIDTH{1'b0}};
        end else begin
            if (S_AXI_ARVALID && !S_AXI_ARREADY && !ar_pending) begin
                S_AXI_ARREADY <= 1'b1;
                ar_addr_latch <= S_AXI_ARADDR;
                ar_pending    <= 1'b1;
            end else begin
                S_AXI_ARREADY <= 1'b0;
            end
            if (S_AXI_RVALID && S_AXI_RREADY)
                ar_pending <= 1'b0;
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_RVALID <= 1'b0;
            S_AXI_RDATA  <= {C_AXI_DATA_WIDTH{1'b0}};
            S_AXI_RRESP  <= 2'b00;
        end else begin
            if (S_AXI_RVALID && S_AXI_RREADY)
                S_AXI_RVALID <= 1'b0;

            if (ar_pending && !S_AXI_RVALID) begin
                S_AXI_RVALID <= 1'b1;
                S_AXI_RDATA  <= regs[ar_addr_latch[ADDR_LSB +: REG_BITS]];
                S_AXI_RRESP  <= 2'b00;
            end
        end
    end

endmodule

`default_nettype wire

