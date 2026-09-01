// ============================================================================
// fvip_axi4lite_props.sv  — v2 (BMC-clean)
//
// Formal Verification IP — AXI4-Lite Slave Register File
// DUT : axi4lite_slave_example (4 x 32-bit word-aligned registers)
// Tool: SymbiYosys / OSS CAD Suite  (smtbmc + boolector, mode prove / cover)
//
// Design rules
//   • All properties in always @(posedge clk) blocks only
//   • Only $past()-based multi-cycle reasoning; every $past() guarded by
//     f_past_valid so step-0 history is never sampled
//   • No `ifdef; instantiated as a plain submodule in fvip_top.sv
//   • No liveness — all "eventually" ideas expressed as safety invariants
//
// Why v1 produced counter-examples
// ----------------------------------
// 1. Section 2 (reset-value asserts) fired at step 0.
//    DUT FFs carry arbitrary initial values; assume(!aresetn) only constrains
//    aresetn, not the outputs.  Two guards required:
//      - f_past_valid        : skip step 0 entirely
//      - !$past(aresetn)     : first cycle of any reset pulse the DUT outputs
//                             still hold pre-reset values; only check from
//                             the SECOND cycle of reset onward
//
// 2. Sections 4/5/7/8 lacked f_past_valid guards, allowing the solver to
//    evaluate them at step 0 with unconstrained FF and counter values.
//
// Section map
//   0 — f_past_valid + reset anchor
//   1 — Master stability ASSUMES  (AW / W / AR)
//   2 — Reset-value ASSERTIONS
//   3 — Slave channel stability   (BVALID / RVALID hold until READY)
//   4 — Response-code correctness
//   5 — READY/VALID correlation
//   6 — READY single-cycle pulse
//   7 — Ghost transaction counters + ordering assertions
//   8 — Presence invariants       (BVALID / RVALID with outstanding txn)
//   9 — Post-reset clean-start
//  10 — COVER witnesses
// ============================================================================

`default_nettype none

module fvip_axi4lite_props #(
    parameter C_AXI_DATA_WIDTH = 32,
    parameter C_AXI_ADDR_WIDTH = 4,
    parameter NUM_REGS         = 4
) (
    input wire clk,
    input wire aresetn,

    // Write Address
    input wire [C_AXI_ADDR_WIDTH-1:0]       awaddr,
    input wire [2:0]                         awprot,
    input wire                               awvalid,
    input wire                               awready,

    // Write Data
    input wire [C_AXI_DATA_WIDTH-1:0]        wdata,
    input wire [(C_AXI_DATA_WIDTH/8)-1:0]    wstrb,
    input wire                               wvalid,
    input wire                               wready,

    // Write Response
    input wire [1:0]                         bresp,
    input wire                               bvalid,
    input wire                               bready,

    // Read Address
    input wire [C_AXI_ADDR_WIDTH-1:0]        araddr,
    input wire [2:0]                         arprot,
    input wire                               arvalid,
    input wire                               arready,

    // Read Data
    input wire [C_AXI_DATA_WIDTH-1:0]        rdata,
    input wire [1:0]                         rresp,
    input wire                               rvalid,
    input wire                               rready
);

    // =========================================================================
    // SECTION 0 — f_past_valid + RESET ANCHOR
    //
    // f_past_valid is 0 at step 0 (via Verilog initial), 1 from step 1 on.
    // Every $past() reference and every assertion over DUT state is guarded
    // by f_past_valid so step-0 unconstrained FF values never cause failures.
    //
    // The assume(!aresetn) forces step 0 to be inside reset so that:
    //   - DUT FFs are driven to 0 on the first clock edge
    //   - Ghost counters are driven to 0 on the first clock edge
    //   - All subsequent steps start from a clean, known baseline
    // =========================================================================

    reg f_past_valid;
    initial f_past_valid = 1'b0;
    always @(posedge clk)
        f_past_valid <= 1'b1;

    always @(posedge clk) begin
        if (!f_past_valid)
            assume(!aresetn);
    end
 
    always @(posedge clk) begin
    if (f_past_valid) begin
        // Enforce AXI AW channel stability
        if ($past(awvalid) && !$past(awready)) begin
            assume(awvalid == 1);
            assume($stable(awaddr));
            assume($stable(awprot));
        end
    end
   end

    // =========================================================================
    // SECTION 1 — MASTER / ENVIRONMENT STABILITY ASSUMES
    //
    // AXI4 §A3.2.1: VALID must not fall before the handshake; payload must
    // be stable over that same window.
    //
    // Guard: f_past_valid && $past(aresetn)
    //   • f_past_valid  — no $past() at step 0
    //   • $past(aresetn)— master is not obligated to hold signals that were
    //                     asserted during the reset period; only enforce
    //                     stability once we have been out of reset for at
    //                     least one cycle
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn)) begin
            if ($past(awvalid) && !$past(awready)) begin
                assume(awvalid);
                assume(awaddr == $past(awaddr));
                assume(awprot == $past(awprot));
            end
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn)) begin
            if ($past(wvalid) && !$past(wready)) begin
                assume(wvalid);
                assume(wdata == $past(wdata));
                assume(wstrb == $past(wstrb));
            end
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn)) begin
            if ($past(arvalid) && !$past(arready)) begin
                assume(arvalid);
                assume(araddr == $past(araddr));
                assume(arprot == $past(arprot));
            end
        end
    end
   

    // =========================================================================
    // SECTION 2 — RESET-VALUE ASSERTIONS
    //
    // All slave outputs must be de-asserted while aresetn = 0.
    //
    // Two guards are BOTH required:
    //
    //   f_past_valid
    //     At step 0 all DUT FFs are arbitrary free variables.  smtbmc /
    //     clk2fflogic does not infer reset values from the Verilog `initial`
    //     for non-initialised regs.  Skip the assertion entirely at step 0.
    //
    //   !$past(aresetn)  — i.e. we were already in reset last cycle
    //     On the FIRST cycle of any reset pulse (aresetn just went 0 after
    //     being 1), the DUT outputs still hold their last active values;
    //     the reset branch only fires on the NEXT posedge.  So we skip
    //     that one transition cycle and only check from the second cycle
    //     of reset onward, when the reset path has definitely applied.
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid  && !$past(aresetn)) begin
            assert(awready == 1'b0);
            assert(wready  == 1'b0);
            assert(bvalid  == 1'b0);
            assert(bresp   == 2'b00);
            assert(arready == 1'b0);
            assert(rvalid  == 1'b0);
            assert(rdata   == 32'b0);
            assert(rresp   == 2'b00);
       end
    end

    // =========================================================================
    // SECTION 3 — SLAVE CHANNEL STABILITY ASSERTIONS
    //
    // AXI4 §A3.2.1 (slave-driven VALIDs): BVALID / RVALID must not fall
    // until the master asserts the corresponding READY.  Payloads (BRESP,
    // RDATA, RRESP) must remain stable over the same window.
    //
    // Guard: f_past_valid && $past(aresetn) && aresetn
    //   Both past AND current cycles must be out of reset.  This excludes:
    //   - Step 0 (no history)
    //   - The reset-deassertion edge (outputs unknown from reset period)
    //   - The first cycle of a new reset (output still holds old value)
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin
            if ($past(bvalid) && !$past(bready)) begin
                assert(bvalid);
                assert(bresp == $past(bresp));
            end
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin
            if ($past(rvalid) && !$past(rready)) begin
                assert(rvalid);
                assert(rdata == $past(rdata));
                assert(rresp == $past(rresp));
            end
        end
    end

    // =========================================================================
    // SECTION 4 — RESPONSE CODE CORRECTNESS
    //
    // This slave always returns OKAY (2'b00).
    // Guard f_past_valid to avoid evaluating against step-0 arbitrary values.
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (bvalid) assert(bresp == 2'b00);
            if (rvalid) assert(rresp == 2'b00);
        end
    end

    // =========================================================================
    // SECTION 5 — READY / VALID CORRELATION
    //
    // The slave must not raise READY on a channel with no VALID pending.
    //
    // This holds because:
    //   The DUT only registers AWREADY/WREADY/ARREADY=1 when it sees the
    //   corresponding VALID high.  The Section 1 stability assumes ensure
    //   VALID is still high when READY is sampled on the following cycle.
    //
    // Guard: f_past_valid && aresetn
    //   f_past_valid prevents evaluation against unconstrained step-0 FFs.
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (awready) assert(awvalid);
            if (wready)  assert(wvalid);
            if (arready) assert(arvalid);
        end
    end

    // =========================================================================
    // SECTION 6 — READY SINGLE-CYCLE PULSE
    //
    // AWREADY, WREADY, ARREADY are asserted for exactly one clock cycle.
    // The DUT's pending-latch (aw_pending, w_pending, ar_pending) blocks
    // re-assertion until the transaction completes, guaranteeing this.
    // Expressed as a safety invariant (no liveness) for bounded provability.
    //
    // Guard: f_past_valid && $past(aresetn) && aresetn
    //   Exclude the reset-transition cycle where outputs briefly appear
    //   non-zero (the registered path to 0 takes one extra cycle).
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin
            if ($past(awready)) assert(!awready);
            if ($past(wready))  assert(!wready);
            if ($past(arready)) assert(!arready);
        end
    end

    // =========================================================================
    // SECTION 7 — GHOST TRANSACTION COUNTERS + ORDERING ASSERTIONS
    //
    // Five 4-bit counters track completed handshakes per channel.
    // Width 4 is sufficient for BMC depth 20 (max 20 handshakes per run).
    //
    //   f_aw_cnt : AW handshakes  (awvalid && awready)
    //   f_w_cnt  : W  handshakes  (wvalid  && wready)
    //   f_b_cnt  : B  handshakes  (bvalid  && bready)
    //   f_ar_cnt : AR handshakes  (arvalid && arready)
    //   f_r_cnt  : R  handshakes  (rvalid  && rready)
    //
    // Write-path ordering
    //   P7a  f_b_cnt  <= f_aw_cnt      no B response without prior AW
    //   P7b  f_b_cnt  <= f_w_cnt       no B response without prior W
    //   P7c  f_aw_cnt <= f_b_cnt + 1   at most 1 outstanding AW (single-issue)
    //   P7d  f_w_cnt  <= f_b_cnt + 1   at most 1 outstanding W
    //
    // Read-path ordering
    //   P7e  f_r_cnt  <= f_ar_cnt      no R response without prior AR
    //   P7f  f_ar_cnt <= f_r_cnt + 1   at most 1 outstanding AR
    //
    // All assertions guarded by f_past_valid:
    //   Without this guard the solver evaluates them at step 0 where the
    //   counters are unconstrained free variables, immediately finding a
    //   state f_b_cnt=5, f_aw_cnt=2 that trivially fails P7a.
    // =========================================================================

    reg [7:0] f_aw_cnt, f_w_cnt, f_b_cnt;
    reg [7:0] f_ar_cnt, f_r_cnt;

    always @(posedge clk) begin
        if (!aresetn) begin
            f_aw_cnt <= 4'd0;
            f_w_cnt  <= 4'd0;
            f_b_cnt  <= 4'd0;
            f_ar_cnt <= 4'd0;
            f_r_cnt  <= 4'd0;
        end else begin
            if (awvalid && awready) f_aw_cnt <= f_aw_cnt + 4'd1;
            if (wvalid  && wready)  f_w_cnt  <= f_w_cnt  + 4'd1;
            if (bvalid  && bready)  f_b_cnt  <= f_b_cnt  + 4'd1;
            if (arvalid && arready) f_ar_cnt <= f_ar_cnt + 4'd1;
            if (rvalid  && rready)  f_r_cnt  <= f_r_cnt  + 4'd1;
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            assert(f_b_cnt <= f_aw_cnt);
            assert(f_b_cnt <= f_w_cnt);
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            assert(f_aw_cnt <= f_b_cnt + 4'd1);
            assert(f_w_cnt  <= f_b_cnt + 4'd1);
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            assert(f_r_cnt <= f_ar_cnt);
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            assert(f_ar_cnt <= f_r_cnt + 4'd1);
    end

    // =========================================================================
    // SECTION 8 — BVALID / RVALID PRESENCE INVARIANTS
    //
    // BVALID must only be high when at least one more AW (and W) has been
    // accepted than B responses delivered.  Same relation for RVALID vs AR/R.
    //
    // These are both genuine DUT properties (enforced by the pending latches)
    // AND strengthening invariants needed to close k-induction: they exclude
    // unreachable states where bvalid=1 but the transaction queues are empty,
    // which would otherwise create bogus induction base-case violations.
    //
    // Guard: f_past_valid — prevent evaluation at step 0 where bvalid and
    // the counters are simultaneously unconstrained free variables.
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (bvalid) begin
                assert(f_aw_cnt > f_b_cnt);
                assert(f_w_cnt  > f_b_cnt);
            end
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (rvalid)
                assert(f_ar_cnt > f_r_cnt);
        end
    end
    // =========================================================================
    // SECTION 7 & 8 — 1-BIT IN-FLIGHT TRACKING (K-INDUCTION SAFE)
    // =========================================================================
    
    /*reg f_aw_inflight;
    reg f_w_inflight;
    reg f_ar_inflight;

    always @(posedge clk) begin
        if (!aresetn) begin
            f_aw_inflight <= 1'b0;
            f_w_inflight  <= 1'b0;
            f_ar_inflight <= 1'b0;
        end else begin
            // Track AW outstanding
            if (awvalid && awready && !(bvalid && bready))
                f_aw_inflight <= 1'b1;
            else if (bvalid && bready && !(awvalid && awready))
                f_aw_inflight <= 1'b0;

            // Track W outstanding
            if (wvalid && wready && !(bvalid && bready))
                f_w_inflight <= 1'b1;
            else if (bvalid && bready && !(wvalid && wready))
                f_w_inflight <= 1'b0;

            // Track AR outstanding
            if (arvalid && arready && !(rvalid && rready))
                f_ar_inflight <= 1'b1;
            else if (rvalid && rready && !(arvalid && arready))
                f_ar_inflight <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            // Ordering constraint: Max 1 outstanding transaction (single-issue)
            if (f_aw_inflight) assert(!(awvalid && awready));
            if (f_w_inflight)  assert(!(wvalid  && wready));
            if (f_ar_inflight) assert(!(arvalid && arready));

            // Presence invariant: No response without prior request
            if (bvalid) begin
                assert(f_aw_inflight || (awvalid && awready));
                assert(f_w_inflight  || (wvalid  && wready));
            end
            if (rvalid) begin
                assert(f_ar_inflight || (arvalid && arready));
            end
        end
    end*/

    // =========================================================================
    // SECTION 9 — POST-RESET CLEAN-START
    //
    // On the first cycle that aresetn transitions 0→1 all slave outputs must
    // be de-asserted; the DUT has not yet processed any request.
    //
    // The DUT satisfies this because its reset path drives all output FFs to
    // 0 on the last in-reset clock edge, so they present 0 on the first
    // out-of-reset cycle.
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && !$past(aresetn) && aresetn) begin
            assert(!awready);
            assert(!wready);
            assert(!bvalid);
            assert(!arready);
            assert(!rvalid);
        end
    end

    // =========================================================================
    // SECTION 10 — COVER WITNESSES  (sby mode cover, depth 25)
    //
    // Reachability witnesses confirm the assumption set is not over-tightened.
    // All covers guarded by f_past_valid && aresetn.
    //
    //   C1  one completed write transaction
    //   C2  one completed read  transaction
    //   C3  two back-to-back writes
    //   C4  two back-to-back reads
    //   C5  write followed by read
    //   C6  AW and W accepted in the same cycle
    //   C7  B handshake immediately followed by AR handshake
    // =========================================================================

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            cover(f_b_cnt >= 4'd1);
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            cover(f_r_cnt >= 4'd1);
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            cover(f_b_cnt >= 4'd2);
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            cover(f_r_cnt >= 4'd2);
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            cover(f_b_cnt >= 4'd1 && f_r_cnt >= 4'd1);
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn)
            cover(awvalid && awready && wvalid && wready);
    end

    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn) && aresetn)
            cover($past(bvalid && bready) && (arvalid && arready));
    end
    // =========================================================================
    // SECTION 7 & 8 REPLACEMENT — IN-FLIGHT TRACKING
    // =========================================================================
    /*reg aw_inflight = 0;
    reg w_inflight  = 0;
    reg ar_inflight = 0;

    always @(posedge clk) begin
        if (!aresetn) begin
            aw_inflight <= 1'b0;
            w_inflight  <= 1'b0;
            ar_inflight <= 1'b0;
        end else begin
            // Track AW outstanding
            if (awvalid && awready && !(bvalid && bready))
                aw_inflight <= 1'b1;
            else if (bvalid && bready && !(awvalid && awready))
                aw_inflight <= 1'b0;

            // Track W outstanding
            if (wvalid && wready && !(bvalid && bready))
                w_inflight <= 1'b1;
            else if (bvalid && bready && !(wvalid && wready))
                w_inflight <= 1'b0;

            // Track AR outstanding
            if (arvalid && arready && !(rvalid && rready))
                ar_inflight <= 1'b1;
            else if (rvalid && rready && !(arvalid && arready))
                ar_inflight <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            // Ordering constraint: Max 1 outstanding transaction (single-issue)
            if (aw_inflight) assert(!(awvalid && awready));
            if (w_inflight)  assert(!(wvalid  && wready));
            if (ar_inflight) assert(!(arvalid && arready));

            // Presence invariant: No response without prior request
            if (bvalid) begin
                assert(aw_inflight || (awvalid && awready));
                assert(w_inflight  || (wvalid  && wready));
            end
            if (rvalid) begin
                assert(ar_inflight || (arvalid && arready));
            end
        end
    end*/

    // =========================================================================
    // SECTION 10 REPLACEMENT — COVER WITNESSES 
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            cover(bvalid && bready);
            cover(rvalid && rready);
            cover(awvalid && awready && wvalid && wready);
            cover($past(bvalid && bready) && (arvalid && arready));
        end
    end

endmodule

`default_nettype wire
/*`default_nettype none

module fvip_axi4lite_props #(
    parameter C_AXI_DATA_WIDTH = 32,
    parameter C_AXI_ADDR_WIDTH = 4,
    parameter NUM_REGS         = 4
) (
    input wire clk,
    input wire aresetn,

    input wire [C_AXI_ADDR_WIDTH-1:0]       awaddr,
    input wire [2:0]                        awprot,
    input wire                              awvalid,
    input wire                              awready,

    input wire [C_AXI_DATA_WIDTH-1:0]       wdata,
    input wire [(C_AXI_DATA_WIDTH/8)-1:0]   wstrb,
    input wire                              wvalid,
    input wire                              wready,

    input wire [1:0]                        bresp,
    input wire                              bvalid,
    input wire                              bready,

    input wire [C_AXI_ADDR_WIDTH-1:0]       araddr,
    input wire [2:0]                        arprot,
    input wire                              arvalid,
    input wire                              arready,

    input wire [C_AXI_DATA_WIDTH-1:0]       rdata,
    input wire [1:0]                        rresp,
    input wire                              rvalid,
    input wire                              rready
);

    // =========================================================================
    // SECTION 0 — f_past_valid + RESET ANCHOR
    // =========================================================================
    reg f_past_valid;
    initial f_past_valid = 1'b0;
    
    always @(posedge clk) begin
        f_past_valid <= 1'b1;
    end

    always @(*) begin
        if (!f_past_valid) begin
            assume(!aresetn);
        end
    end

    // =========================================================================
    // SECTION 1 — MASTER / ENVIRONMENT STABILITY ASSUMES
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn)) begin
            if ($past(awvalid) && !$past(awready)) begin
                assume(awvalid);
                assume(awaddr == $past(awaddr));
                assume(awprot == $past(awprot));
            end
            if ($past(wvalid) && !$past(wready)) begin
                assume(wvalid);
                assume(wdata == $past(wdata));
                assume(wstrb == $past(wstrb));
            end
            if ($past(arvalid) && !$past(arready)) begin
                assume(arvalid);
                assume(araddr == $past(araddr));
                assume(arprot == $past(arprot));
            end
        end
    end

    // =========================================================================
    // SECTION 2 — RESET-VALUE ASSERTIONS
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && !$past(aresetn)) begin
            assert(awready == 1'b0);
            assert(wready  == 1'b0);
            assert(bvalid  == 1'b0);
            assert(arready == 1'b0);
            assert(rvalid  == 1'b0);
        end
    end

    // =========================================================================
    // SECTION 3 — SLAVE CHANNEL STABILITY ASSERTIONS
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin
            if ($past(bvalid) && !$past(bready)) begin
                assert(bvalid);
                assert(bresp == $past(bresp));
            end
            if ($past(rvalid) && !$past(rready)) begin
                assert(rvalid);
                assert(rdata == $past(rdata));
                assert(rresp == $past(rresp));
            end
        end
    end

    // =========================================================================
    // SECTION 4 — RESPONSE CODE CORRECTNESS
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (bvalid) assert(bresp == 2'b00);
            if (rvalid) assert(rresp == 2'b00);
        end
    end

    // =========================================================================
    // SECTION 5 — READY / VALID CORRELATION
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (awready) assert(awvalid);
            if (wready)  assert(wvalid);
            if (arready) assert(arvalid);
        end
    end

    // =========================================================================
    // SECTION 6 — READY SINGLE-CYCLE PULSE
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin
            if ($past(awready)) assert(!awready);
            if ($past(wready))  assert(!wready);
            if ($past(arready)) assert(!arready);
        end
    end

    // =========================================================================
    // SECTION 7 & 8 — 1-BIT IN-FLIGHT TRACKING (K-INDUCTION SAFE)
    // =========================================================================
    reg f_aw_inflight;
    reg f_w_inflight;
    reg f_ar_inflight;

    always @(posedge clk) begin
        if (!aresetn) begin
            f_aw_inflight <= 1'b0;
            f_w_inflight  <= 1'b0;
            f_ar_inflight <= 1'b0;
        end else begin
            if (awvalid && awready && !(bvalid && bready))
                f_aw_inflight <= 1'b1;
            else if (bvalid && bready && !(awvalid && awready))
                f_aw_inflight <= 1'b0;

            if (wvalid && wready && !(bvalid && bready))
                f_w_inflight <= 1'b1;
            else if (bvalid && bready && !(wvalid && wready))
                f_w_inflight <= 1'b0;

            if (arvalid && arready && !(rvalid && rready))
                f_ar_inflight <= 1'b1;
            else if (rvalid && rready && !(arvalid && arready))
                f_ar_inflight <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            if (f_aw_inflight) assert(!(awvalid && awready));
            if (f_w_inflight)  assert(!(wvalid  && wready));
            if (f_ar_inflight) assert(!(arvalid && arready));

            if (bvalid) begin
                assert(f_aw_inflight || (awvalid && awready));
                assert(f_w_inflight  || (wvalid  && wready));
            end
            if (rvalid) begin
                assert(f_ar_inflight || (arvalid && arready));
            end
        end
    end

    // =========================================================================
    // SECTION 9 — POST-RESET CLEAN-START
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && !$past(aresetn) && aresetn) begin
            assert(!awready);
            assert(!wready);
            assert(!bvalid);
            assert(!arready);
            assert(!rvalid);
        end
    end

    // =========================================================================
    // SECTION 10 — COVER WITNESSES 
    // =========================================================================
    always @(posedge clk) begin
        if (f_past_valid && aresetn) begin
            cover(bvalid && bready);
            cover(rvalid && rready);
            cover(awvalid && awready && wvalid && wready);
            cover($past(bvalid && bready) && (arvalid && arready));
        end
    end

endmodule

`default_nettype wire */





