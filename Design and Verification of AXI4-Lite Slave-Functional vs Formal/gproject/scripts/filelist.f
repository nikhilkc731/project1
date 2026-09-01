// AXI4-Lite UVM VIP - VCS file list
//
// Usage: vcs -f filelist.f ...

// Include paths
+incdir+../axi4lite_agent
+incdir+../env
+incdir+../seq_lib
+incdir+../tests

// Interface (must be compiled before packages that reference it)
../axi4lite_agent/axi4lite_if.sv

// Packages (order matters: agent -> seq -> env -> test)
../axi4lite_agent/axi4lite_agent_pkg.sv
../seq_lib/axi4lite_seq_pkg.sv
../env/axi4lite_env_pkg.sv
../tests/axi4lite_test_pkg.sv

// RTL
../rtl/axi4lite_slave_example.sv

// Testbench top
../tb/tb_top.sv
