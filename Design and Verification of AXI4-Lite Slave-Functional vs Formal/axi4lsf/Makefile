# =============================================================================
# Makefile — AXI4-Lite Slave FVIP
#
# Targets:
#   make prove    — BMC + k-induction (depth 20)
#   make cover    — reachability / cover traces (depth 25)
#   make all      — both prove and cover
#   make clean    — remove all SymbiYosys output directories
#   make help     — print this summary
#
# Requires OSS CAD Suite in PATH (sby, yosys, boolector).
# =============================================================================

SBY     := sby
SCRIPT  := /home/nikhil/projects/axi4lsf/fv/fvip_axi4lite.sby

.PHONY: all prove cover clean help

all: prove cover

bmc:
	$(SBY) -f $(SCRIPT) bmc
prove:
	$(SBY) -f $(SCRIPT) prove

cover:
	$(SBY) -f $(SCRIPT) cover

clean:
	rm -rf fv/fvip_axi4lite_prove fv/fvip_axi4lite_cover

help:
	@echo ""
	@echo "  make prove   — run BMC + k-induction proof (depth 20)"
	@echo "  make cover   — run cover / witness traces  (depth 25)"
	@echo "  make all     — run both"
	@echo "  make clean   — remove output directories"
	@echo ""

