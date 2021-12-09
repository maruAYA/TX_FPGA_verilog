module FREQ_DOUBLE(
    input   reset,
    input   GCLK,
    input   MODULE_ENA,
    output reg  [31:0]  DDS_OUT,
    output  DDS_DATA_VALID,
    output  [15:0] Idata,
    output  [15:0] Qdata
);
assign Idata = DDS_OUT[15:0];
assign Qdata = DDS_OUT[31:15];
wire [31:0] DDS_DIRECT_1;
wire [31:0] DDS_DIRECT_2;
wire DDS_DATA_VALID_1;
wire DDS_DATA_VALID_2;
reg [15:0]  DDS_1_L;
reg [15:0]  DDS_1_H;
reg [15:0]  DDS_2_L;
reg [15:0]  DDS_2_H;
assign  DDS_DATA_VALID = DDS_DATA_VALID_1 & DDS_DATA_VALID_2;
initial begin
        DDS_1_L <= 16'b0;
        DDS_1_H <= 16'b0;
        DDS_2_L <= 16'b0;
        DDS_2_H <= 16'b0;
        DDS_OUT <= 32'd0;
end
always @(posedge GCLK) begin
    if(reset == 1 || MODULE_ENA == 0) begin
        DDS_1_L <= 16'b0;
        DDS_1_H <= 16'b0;
        DDS_2_L <= 16'b0;
        DDS_2_H <= 16'b0;
        DDS_OUT <= 32'd0;
    end
    else begin
        DDS_1_L <= DDS_DIRECT_1[15:0];
        DDS_1_H <= DDS_DIRECT_1[31:16];
        DDS_2_L <= DDS_DIRECT_2[15:0];
        DDS_2_H <= DDS_DIRECT_2[31:16];
        DDS_OUT[15:0] <= (($signed(DDS_1_L)) >>> 1) + (($signed(DDS_2_L)) >>> 1);
        DDS_OUT[31:16] <= (($signed(DDS_1_H)) >>> 1) + (($signed(DDS_2_H)) >>> 1);
    end
end

dds_compiler_1 DDS_1(
    .aclk   (GCLK),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (DDS_DIRECT_1),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid (DDS_DATA_VALID_1)
);

dds_compiler_2 DDS_2(
    .aclk   (GCLK),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (DDS_DIRECT_2),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid (DDS_DATA_VALID_2)
);

// always @(posedge GCLK) begin
//     if(reset == 1 || MODULE_ENA == 0) begin
//         DDS_OUT <= 32'd0;
//         {DDS_REG_1_H, DDS_REG_1_L} <= 32'd0;
//         {DDS_REG_2_H, DDS_REG_2_L} <= 32'd0;
//     end
//     else begin
//     DDS_OUT <= 32'd0;
//     {DDS_REG_1_H, DDS_REG_1_L} <= {0,DDS_DATA_1[29:15],0,DDS_DATA_1[14:0]};
//     {DDS_REG_2_H, DDS_REG_2_L} <= {0,DDS_DATA_2[29:15],0,DDS_DATA_2[14:0]};
//     //Correcting situation that don't cause overflow-Low 16 bits
//     if(DDS_REG_1_L[14] == 1 && DDS_REG_2_L[14] == 0) begin
//             DDS_OUT[15:0] <= DDS_REG_1_L + DDS_REG_2_L;
//             if(DDS_OUT[15] == 0 && DDS_OUT[14] == 1) begin
//                 DDS_OUT[15] <= 1;
//             end
//         end
//     else if(DDS_REG_1_L[14] == 0 && DDS_REG_2_L[14] == 1) begin
//             DDS_OUT[15:0] <= DDS_REG_1_L + DDS_REG_2_L;
//             if(DDS_OUT[15] == 0 && DDS_OUT[14] == 1) begin
//                 DDS_OUT[15] <= 1;
//     end
//     else begin
//         DDS_OUT[15:0] <= DDS_REG_1_L + DDS_REG_2_L;
//     end
//     //High 16 bits
//     if(DDS_REG_1_H[14] == 1 && DDS_REG_2_H[14] == 0) begin
//             DDS_OUT[31:16] <= DDS_REG_1_H + DDS_REG_2_H;
//             if(DDS_OUT[31] == 0 && DDS_OUT[30] == 1) begin
//                 DDS_OUT[31] <= 1;
//             end
//         end
//     end
//     else if(DDS_REG_1_H[14] == 0 && DDS_REG_2_H[14] == 1) begin
//             DDS_OUT[31:16] <= DDS_REG_1_H + DDS_REG_2_H;
//             if(DDS_OUT[31] == 0 && DDS_OUT[30] == 1) begin
//                 DDS_OUT[31] <= 1;
//             end
//     end
//     else begin
//         DDS_OUT[31:16] <= DDS_REG_1_H + DDS_REG_2_H;
//     end    
//     end
// end
endmodule