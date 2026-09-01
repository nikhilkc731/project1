AXI4-Lite Slave Peripheral: Formal vs. Functional Verification

• Designed a parameterised 4×32-bit AXI4-Lite slave in synthesisable SystemVerilog with byte-strobe-aware write logic and single-cycle handshake control.

• Built a 13-module UVM verification IP (driver, monitor, scoreboard, reference model, virtual sequences, 10 covergroups, 11 sequences, 11 tests) on Synopsys VCS; debugged monitor-to-scoreboard mismatches traced to stale transaction objects.

• Drove coverage to 98.35% overall (100% line,100% branch, 91.77% toggle, 100% functional) through active analysis of coverage and cross-coverage gaps and targeted test writing — not passive regression convergence.

• Developed a formal verification IP with 31 SVA assertions, 24 assumptions, and 25 cover properties (VALID/READY handshake, response/data stability); achieved BMC PASS and reachability cover PASS at depth 60 using SymbiYosys with the Boolector SMT solver, validated through counterexample and vacuity analysis and BMC-vs-induction comparison.
