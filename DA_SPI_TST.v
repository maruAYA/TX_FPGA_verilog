module DA_SPI_TST(
    input   Cir_reset,
    input   clk_reset,
    input   DA_SPI_IN,
    // input   EXCLK,
    input   GCLK,
    input   SAMPLE_CLK,
    input   lock,
    input   DA_PLL_LOCK,
    output  reg Cir_resetn,

    output reg  DA_SCLK_OUT,
    output reg  DA_SPI_OUT,
    output reg  DA_CS_OUT,
    output reg  DA_EN_OUT
    // output  DA_SCLK_OUT,
    // output  DA_SPI_OUT,
    // output  DA_CS_OUT,
    // output reg  DA_EN_OUT

    // output [7:0]    DA_PC,
    // output  [39:0]   DA_INSTR,
    // output  [5:0]   DA_CNT,
    // output  [5:0]   DA_TAR_CNT,
    // output  reg DA_CONTROL
);
// wire SAMPLE_CLK;
// wire GCLK;
reg DA_CONTROL;
wire DA_READY;
wire lock;
// reg clk_resetn;
reg [31:0]  KEY_CNT;
reg CNT_0_EN;
reg [31:0]  KEY_CNT_1;
reg CNT_1_EN;
reg [31:0] KEY_CNT_2;
reg CNT_2_EN;
reg [31:0]  PC_DELAY_CNT;
wire DA_CS;
wire DA_SPI;
wire DA_SCLK;
wire DA_EN;
reg [1:0] CIR_CNT;
reg DA_SPI_reset;
reg CS_Buffer;
initial begin
    Cir_resetn <= 0;
    // clk_resetn <= 0;
    CNT_0_EN <= 0;
    CNT_1_EN <= 0;
    CNT_2_EN <= 0;
    KEY_CNT <= 32'd0;
    KEY_CNT_1 <= 32'd0;
    KEY_CNT_2 <= 32'd0;
    DA_CONTROL <= 0;
    PC_DELAY_CNT <= 32'd0;
    DA_CS_OUT <= 1;
    DA_SCLK_OUT <= 0;
    DA_SPI_OUT <= 0;
    DA_EN_OUT <= 0;
    CIR_CNT <= 2'd0;
    DA_SPI_reset = 1;
    CS_Buffer <= 1;
end
always @(posedge SAMPLE_CLK) begin
    DA_CS_OUT <= CS_Buffer;
    CS_Buffer <= DA_CS;
    DA_SCLK_OUT <= (~DA_SCLK) & lock;
    DA_SPI_OUT <= DA_SPI;
    // DA_EN_OUT <= DA_EN;

end
// ila_0   ILA(
//     .clk    (SAMPLE_CLK),
//     .probe0 (DA_PLL_LOCK),
//     .probe1 (DA_SPI_OUT),
//     .probe2 (DA_CS_OUT),
//     .probe3 (DA_SCLK_OUT),
//     .probe4 (DA_SPI_IN),
//     .probe5 (Cir_reset)
// );
// clk_wiz_0   MCMM(
//     .clk_in1    (EXCLK),
//     .clk_out1   (GCLK),
//     .clk_out2   (SAMPLE_CLK),
//     .reset      (~clk_reset),
//     .locked     (lock)
// );
//Anti-vibration for button
// 2021.11.5
//For circuit part reset
always @(posedge GCLK) begin
    if(Cir_reset == 0) begin
        KEY_CNT <= 32'd0;
        CNT_0_EN <= 1;
        Cir_resetn <= 1;
    end
    else begin
        if(KEY_CNT == 32'd500) begin
            KEY_CNT <= 32'd0;
            Cir_resetn <= 0;
            CNT_0_EN <= 0;
        end
        else if(CNT_0_EN == 1) begin
            KEY_CNT <= KEY_CNT + 1;
            Cir_resetn <= 1;
        end
        else if(CNT_0_EN == 0) begin
            Cir_resetn <= 0;
        end
    end
end

//for Clock part reset
// always @(posedge GCLK) begin
//     if(clk_reset == 0) begin
//         KEY_CNT_1 <= 32'd0;
//         CNT_1_EN <= 1;
//     end
//     else begin
//         if(KEY_CNT_1 == 32'd1_999_999) begin
//             KEY_CNT_1 <= 32'd0;
//             clk_resetn <= 0;
//             CNT_1_EN <= 0;
//         end
//         else if(CNT_1_EN == 1) begin
//             KEY_CNT_1 <= KEY_CNT_1 + 1;
//             clk_resetn <= 1;
//         end
//         else if(CNT_1_EN == 0) begin
//             clk_resetn <= 0;
//         end
//     end
// end
//for Maunal PC increase
// // Manual controlled PC increasing-DEBUG USED ONLY
// always @(posedge GCLK) begin
//     if(DA_CONTROL_KEY == 0) begin
//         KEY_CNT_2 <= 32'd0;
//         CNT_2_EN <= 1;
//     end
//     else begin
//         if(KEY_CNT_2 == 32'd500) begin
//             KEY_CNT_2 <= 32'd0;
//             DA_CONTROL <= 0; 
//             CNT_2_EN <= 0;
//         end
//         else if(CNT_2_EN == 1) begin
//             KEY_CNT_2 <= KEY_CNT_2 + 1;
//             DA_CONTROL <= 1;
//         end
//         else if(CNT_2_EN == 0) begin
//             DA_CONTROL <= 0;
//         end
//     end
// end
// Automatic PC increase at a fixed speed
// 2021.11.5
always @(posedge GCLK) begin
    if(Cir_resetn == 1) begin
        PC_DELAY_CNT <= 32'd0;
        DA_CONTROL <= 0;
    end
    else begin
        if(PC_DELAY_CNT == 32'h0000_0050) begin
            DA_CONTROL <= 1;
            PC_DELAY_CNT <= PC_DELAY_CNT + 1;
        end
        else if(PC_DELAY_CNT == 32'h0000_0055) begin
                PC_DELAY_CNT <= 32'h0;
                DA_CONTROL <= 0;
            end
        else begin
                PC_DELAY_CNT <= PC_DELAY_CNT + 1;
        end
    end
end
//SPI module reset generation. Enable the SPI for three times to make sure bits written into reg.
//2021.11.13-> DA_EN is the inner signal of DA_SPI_RE, do not change //
//2021.11.12
always @(posedge GCLK) begin
    if(Cir_resetn == 1) begin
        DA_SPI_reset <= 1;
        CIR_CNT <= 2'd0;
        DA_EN_OUT <= 0;
    end
    else begin
        if(CIR_CNT == 2'b11 && DA_EN == 1 && DA_CONTROL == 0) begin
            DA_SPI_reset <= 0;
            DA_EN_OUT <= 1;
        end
        else if(DA_EN == 1 && CIR_CNT < 2'b11 && DA_CONTROL == 0) begin
            DA_SPI_reset <= 1;
            CIR_CNT <= CIR_CNT + 1;
        end
        else begin
            DA_SPI_reset <= 0;
        end
    end
end
// Corrected SPI module with changing Information byte length, using CS to divide.
//2021.11.7
DA_SPI_RE DA(
    .GCLK   (GCLK),
    .PC_CONTROL (DA_CONTROL),
    .DA_CS      (DA_CS),
    .DA_READY   (DA_EN),
    .DA_SCLK    (DA_SCLK),
    .DA_SPI_OUT (DA_SPI),
    .CLM_LOCK       (lock),
    .reset      (DA_SPI_reset)
    // .DA_PC      (DA_PC),
    // .DA_INSTR   (DA_INSTR),
    // .DA_CNT     (DA_CNT),
    // .DA_TAR_CNT     (DA_TAR_CNT)
);
//Created in 2021.11.7, modified in 2021.11.8, give the basic function of transmitting without CS controlling
// DA_SPI_BASE DA(
//     .GCLK   (GCLK),
//     .DA_CONTROL (DA_CONTROL),
//     .DA_CS      (DA_CS),
//     .DA_READY   (DA_EN),
//     .DA_SCLK    (DA_SCLK),
//     .DA_SPI (DA_SPI),
//     .reset      (Cir_resetn),
//     .CLM_LOCK   (lock)
//     //     .DA_PC      (DA_PC),
//     // .DA_INSTR   (DA_INSTR),
//     // .DA_CNT     (DA_CNT)
// );
endmodule