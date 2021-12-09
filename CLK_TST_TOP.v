module CLK_TOP(
    input EXCLK,
    input clk_reset,
    input Cir_reset,
    input MOD_SEL_KEY,
    input DA_PLL_LOCK,
    input   DA_DATA_CLK,
    output  lock,


    output  [15:0] Idata,
    output  [15:0] Qdata,


    output  ADRF_EN,
    output  ADRF_SCLK_OUT,
    output  ADRF_SPI_OUT,
    output  ADRF_CS,
    output  DA_EN_OUT,
    output  DA_SCLK_OUT,
    output  DA_SPI_OUT,
    output  DA_CS_OUT,
    output  DA_RESET,

    input   DA_SPI_IN,

    output  [5:0]   TQPM

);
wire GCLK;
wire SAMPLE_CLK;
wire clk_resetn;
wire Cir_resetn;
wire ADRF_WRIEND;
wire DA_WRIEND;

wire [15:0] Idata;
wire [15:0] Qdata;
wire [31:0] DDS_OUT;
wire DATA_CLK;
wire DDS_DATA_VALID;
wire [3:0] MOD_SEL;
wire [31:0] DDS_DIRECT;
// wire [2:0]  FUN_gpio;


assign clk_resetn = ~clk_reset;
// assign Cir_resetn = ~Cir_reset;
// assign ADRF_EN = DA_WRIEND & ADRF_WRIEND;
// assign  DA_EN = ADRF_EN;
// assign  DA_SCLK_OUT = DA_SCLK & DA_WRIEND;
// assign  ADRF_SCLK_OUT   = (~ADRF_SCLK) & ADRF_WRIEND;
// assign  DA_RESET = Cir_resetn;
// assign Cir_resetn = ~Cir_reset;
assign ADRF_EN = ADRF_WRIEND;
assign  ADRF_SCLK_OUT   = (~ADRF_SCLK) & (~ADRF_WRIEND);
assign  DA_RESET = Cir_resetn;
assign  Idata = DDS_OUT[15:0];
// Roll_off testing
assign  Qdata = DDS_OUT[31:16];
assign  TQPM = 6'b111111;
clk_wiz_0 MMCM0(
    .clk_in1    (EXCLK),
    .reset      (clk_resetn),
    .clk_out1   (GCLK),
    .clk_out2   (SAMPLE_CLK),
    .clk_out3   (ADRF_SCLK),
    .clk_out4   (DA_SPI_SCLK),
    .clk_out5   (DATA_CLK),
    .locked     (lock)
);

ADRF_SPI SPI(
    // .DA_SCLK    (DA_SCLK),
    .ADRF_SCLK  (ADRF_SCLK),
    // .DA_WRIEND  (DA_WRIEND),
    // .DA_CS   (DA_CS),
    // .DA_SPI_OUT     (DA_SPI_OUT),
    .ADRF_WRIEND  (ADRF_WRIEND),
    .ADRF_CS   (ADRF_CS),
    .ADRF_SPI_OUT     (ADRF_SPI_OUT),
    .CMT_LOCKED     (lock),
    .reset          (0),
    .SPI_EN         (1)
);


ila_0   ILA(
    .clk    (SAMPLE_CLK),
    .probe0     (Idata),
    .probe1     (DA_SPI_IN),
    .probe2     (DA_PLL_LOCK),
    .probe3     (DA_DATA_CLK),
    .probe4     (DA_SCLK_OUT),
    .probe5     (DA_SPI_OUT),
    .probe6     (DA_CS_OUT),
    .probe7     (MOD_SEL),
    .probe8     (Cir_resetn)
);

//  design_1_wrapper PS(
//     // .gpio_FUN_tri_o (FUN_gpio)
//  );

// dds_compiler_0 DDS(
//      .aclk   (DATA_CLK),  // output wire m_axis_data_tvalid
//      .m_axis_data_tdata  (DDS_OUT),    // output wire [15 : 0] m_axis_data_tdata
//      .m_axis_data_tvalid (DDS_DATA_VALID)
// );

FREQ_DOM_SHAPING FREQ(
    .MOD_SEL_KEY    (MOD_SEL_KEY),
    .reset          (Cir_resetn | ~DA_EN_OUT),
    .GCLK           (DATA_CLK),
    .MUX_DDS_OUT    (DDS_OUT),
    // .MOD_SEL_KEY        (FUN_gpio),
    .DDS_DATA_VALID (DDS_DATA_VALID),
    .DDS_DIRECT     (DDS_DIRECT)
);

// DAC_FIFO    FIFO(
//     .GCLK   (SAMPLE_CLK),
//     .Idata  (DDS_OUT[31:16]),
//     .Qdata  (DDS_OUT[15:0]),
//     .Idata_OUT  (Idata),
//     .Qdata_OUT  (Qdata),
//     .DA_DATA_CLK    (DATA_CLK),
//     .DDS_CLK        (DATA_CLK),
//     .reset          (Cir_resetn),
//     .DDS_DATA_VALID (DDS_DATA_VALID),
//     .DA_EN          (DA_EN)
// );
DA_SPI_TST  DA_SPI(
    .Cir_reset  (Cir_reset),
    .Cir_resetn (Cir_resetn),
    .clk_reset  (clk_reset),
    // .DA_SPI_IN  (DA_SPI_IN),
    .GCLK      (DA_SPI_SCLK),
    .SAMPLE_CLK (SAMPLE_CLK),
    .DA_SCLK_OUT    (DA_SCLK_OUT),
    .DA_SPI_OUT     (DA_SPI_OUT),
    .DA_CS_OUT      (DA_CS_OUT),
    .DA_EN_OUT      (DA_EN_OUT),
    .lock           (lock)
);

// TQPM TQPM(
//     .TQPM_OUT  (TQPM),
//     .GCLK      (SAMPLE_CLK)
// );

endmodule