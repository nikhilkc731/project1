// AXI4-Lite type definitions

typedef enum bit [1:0] {
  AXI_RESP_OKAY   = 2'b00,
  AXI_RESP_EXOKAY = 2'b01,
  AXI_RESP_SLVERR = 2'b10,
  AXI_RESP_DECERR = 2'b11
} axi4lite_resp_t;

typedef enum bit {
  AXI4LITE_WRITE = 1'b0,
  AXI4LITE_READ  = 1'b1
} axi4lite_dir_t;

typedef enum bit [2:0] {
  AXI_PROT_UNPRIV_SECURE_DATA   = 3'b000,
  AXI_PROT_PRIV_SECURE_DATA     = 3'b001,
  AXI_PROT_UNPRIV_NONSEC_DATA   = 3'b010,
  AXI_PROT_PRIV_NONSEC_DATA     = 3'b011,
  AXI_PROT_UNPRIV_SECURE_INSTR  = 3'b100,
  AXI_PROT_PRIV_SECURE_INSTR    = 3'b101,
  AXI_PROT_UNPRIV_NONSEC_INSTR  = 3'b110,
  AXI_PROT_PRIV_NONSEC_INSTR    = 3'b111
} axi4lite_prot_t;
