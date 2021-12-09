module FREQ_DOM_SHAPING(
    input   MOD_SEL_KEY,
    input   reset,
    input   GCLK,
    output  [31:0]  MUX_DDS_OUT,
    output  reg [3:0] MOD_SEL,
    output  DDS_DATA_VALID,
    output  [15:0]  DDS_DIRECT
);
//Mode select reg,
//0x0: Single
//0x1:  Double or more
//0x2:  Freq_SWEEPING
//0x3:  Required shape
reg MOD_SEL_REC;
reg KEY_CNT_EN;
reg [31:0] KEY_CNT;
wire [31:0] DDS_OUT_0;
wire [31:0] DDS_OUT_1;
wire [31:0] DDS_OUT_2;
wire [31:0] DDS_OUT_3;
wire DDS_DATA_VALID_0;
wire DDS_DATA_VALID_1;
wire DDS_DATA_VALID_2;
wire DDS_DATA_VALID_3;

assign MUX_DDS_OUT = reset ? 32'd0 : DDS_OUT_0 | DDS_OUT_1 | DDS_OUT_2 | DDS_OUT_3; 
assign  DDS_DATA_VALID = DDS_DATA_VALID_0 | DDS_DATA_VALID_1 | DDS_DATA_VALID_2 | DDS_DATA_VALID_3;
initial begin
    MOD_SEL <= 4'b0001;
    MOD_SEL_REC <= 1;
    KEY_CNT <= 32'd0;
    KEY_CNT_EN <= 0;
end

//First attempy for key noise nulling
// always @(posedge GCLK) begin
//     if(MOD_SEL == 4'd0) begin
//         MOD_SEL <= 4'd1;
//     end
//     else begin
//         if(MOD_SEL_KEY == 0 && MOD_SEL_REC == 1 && KEY_CNT == 23'd9_999_999) begin
//             MOD_SEL <= (MOD_SEL << 1);
//             KEY_CNT <= 23'd0;
//         end
//         else begin
//             if(MOD_SEL_KEY == 0 && MOD_SEL_REC == 1 && KEY_CNT < 23'd9_999_999) begin
//                 KEY_CNT <= KEY_CNT + 1;
//             end
//             else if(MOD_SEL_KEY == 1 && MOD_SEL_REC == 1&& KEY_CNT != 23'd0) begin
//                 KEY_CNT <= 23'd0;
//                 MOD_SEL_REC <= MOD_SEL_KEY;
//             end
//         end
//     end
// end
//Attempt 2
// always @(negedge MOD_SEL_KEY) begin
//     if(KEY_CNT < 32'd99_999_999) begin
//         KEY_CNT_EN <= 1;
//     end
//     else begin
//         KEY_CNT_EN <= 0;
//     end
// end
always @(posedge GCLK) begin
    if(MOD_SEL == 4'd0) begin
        MOD_SEL <= 4'd1;
    end
    if(MOD_SEL_KEY == 1) begin
        KEY_CNT <= 32'd0;
    end
    else begin
        if(KEY_CNT == 32'd99_999_999) begin
            KEY_CNT <= 32'd0;
            MOD_SEL <= (MOD_SEL << 1);
        end
        else begin
            KEY_CNT <= KEY_CNT + 1;
        end
    end
end
//include DDS0
FREQ_SINGLE SINGLE_MODE(
    .reset  (reset),
    .GCLK   (GCLK),
    .MODULE_ENA (MOD_SEL[0]),
    .DDS_OUT    (DDS_OUT_0),
    .DDS_DATA_VALID (DDS_DATA_VALID_0),
    .DDS_DATA       (DDS_DIRECT)
);
//include DDS1 and DDS2
FREQ_DOUBLE DOUBLE_MODE(
    .reset  (reset),
    .GCLK   (GCLK),
    .MODULE_ENA (MOD_SEL[1]),
    .DDS_OUT    (DDS_OUT_1),
    .DDS_DATA_VALID (DDS_DATA_VALID_1)
);
//include DDS3
FREQ_SWEEPING SWEEPING_MODE(
    .reset  (reset),
    .GCLK   (GCLK),
    .MODULE_ENA (MOD_SEL[2]),
    .DDS_OUT    (DDS_OUT_2),
    .DDS_DATA_VALID (DDS_DATA_VALID_2)
);
FREQ_ROLL ROLL_OFF_MODE(
    .reset  (reset),
    .GCLK   (GCLK),
    .MODULE_ENA (MOD_SEL[3]),
    .DDS_OUT    (DDS_OUT_3),
    .DDS_DATA_VALID (DDS_DATA_VALID_3)
);
endmodule

