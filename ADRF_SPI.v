module ADRF_SPI(
    input   DA_SCLK,
    input   ADRF_SCLK,
    // output wire  DA_SPI_OUT,
    output wire  ADRF_SPI_OUT,
    output  wire DA_WRIEND,
    output  wire ADRF_WRIEND,
    // output  wire DA_CS,
    output  wire ADRF_CS,
    //output  wire [7:0]  DA_SPI
    input   CMT_LOCKED,
    input   reset,
    input   SPI_EN
);
wire DA_READY;
wire DA_CONTROL;
wire ADRF_READY;
wire ADRF_CONTROL;


// DA_SPI_TST  T_DA(
//     .reset  (reset)   
// );

ADRF    T_ADRF(
    .ADRF_CONTROL (ADRF_CONTROL),
    .GCLK       (ADRF_SCLK),
    .ADRF_CS      (ADRF_CS),
    .ADRF_READY   (ADRF_READY),
    .ADRF_SPI_OUT   (ADRF_SPI_OUT),
    .reset          (reset)
);

//ADRFSPI T_ADRFSPI(
    //.GCLK  (GCLK),
    //.ADRF_CS    (ADRF_CS),
    //.ADRF_READY (ADRF_READY),
    //.ADRF_SPI   (ADRF_SPI)
//);

CONTROL  T_CONTROL(
    .DA_READY   (DA_READY),
    .DA_CONTROL (DA_CONTROL),
    .ADRF_SCLK  (ADRF_SCLK),
    .DA_SCLK    (DA_SCLK),
    .DA_WRIEND  (DA_WRIEND),
    .DA_CS      (DA_CS),
    .ADRF_READY   (ADRF_READY),
    .ADRF_CONTROL (ADRF_CONTROL),
    .ADRF_WRIEND  (ADRF_WRIEND),
    .ADRF_CS      (ADRF_CS),
    .reset          (reset),
    .CMT_LOCKED     (CMT_LOCKED),
    .SPI_EN         (SPI_EN)
);
endmodule
