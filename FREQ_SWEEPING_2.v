module FREQ_SWEEPING(
    input   reset,
    input   GCLK,
    input   MODULE_ENA,
    output  DDS_DATA_VALID,
    output  [31:0]  DDS_OUT,
    output  [15:0]  Idata,
    output  reg [15:0]  PHASE_INCREASE_NUM,
    output  reg [31:0]  CIRCULAR_CNT
);
// First attempt: Giving Phase incremetentation back to DDS core, and change this value according to the times DDS_OUT reaching 0;
 //Reg for Phase Incremtentation selecting, devide the sweepin process into 16 parts
  //0010 0000 0000 0000 stands for 1.5625MHz
// Counter for circulars
reg [4:0]   PHASE_CNT;
// reg [23:0]  PHASE;
// ***************************************** //
// Second attempt:   Giving the minimum phase Incrementation(largest DDS output frequency) and delaying the output of DDS by dividing frequency or dividing clk;
// Second attempt of dividing data failed, changing to dividing clk;
// reg [3:0] CLK_SEL;//DDS clk SEL
// reg [15:0]  CIRCULAR_CNT;//Counter for ciculars
// reg DDS_CLK;
// reg [3:0] CLK_CNT;//clk counter
wire [31:0] DDS_DATA;
assign  Idata = DDS_DATA[15:0];

assign DDS_OUT = MODULE_ENA ? DDS_DATA:32'b0;

initial begin
     PHASE_CNT <= 5'd0;
     PHASE_INCREASE_NUM <= 16'h0800;
     CIRCULAR_CNT <= 32'd0;
end
always @(posedge GCLK) begin
    if(reset == 1 || MODULE_ENA == 0) begin
        PHASE_CNT <= 4'd0;
        CIRCULAR_CNT <= 32'd0;
        PHASE_INCREASE_NUM <= 16'h0800;
    end
    else begin
        if(CIRCULAR_CNT == 32'h00ffffff && PHASE_CNT < 4'd15) begin
            PHASE_CNT <= PHASE_CNT + 1;
            PHASE_INCREASE_NUM <= PHASE_INCREASE_NUM + 16'h0800;
            CIRCULAR_CNT <= 32'd0;
        end
        else if(CIRCULAR_CNT == 32'h00ffffff && PHASE_CNT == 4'd15) begin
            PHASE_CNT <= 4'd0;
            CIRCULAR_CNT <= 32'd0;
            PHASE_INCREASE_NUM <= 16'h0800;
        end
        else begin
            CIRCULAR_CNT <= CIRCULAR_CNT + 1;
        end
    end
end


// always @(posedge GCLK) begin
//     if(reset == 1) begin
//         PHASE <= 24'd0;
//     end
//     else begin
//         if(PHASE == 24'hffffff) begin
//             PHASE <= 24'd0;
//         end
//         else begin
//             PHASE <= PHASE + PHASE_INCREASE_NUM;
//         end
//     end
// end

// always @(posedge GCLK) begin
//     if(reset == 1 || MODULE_ENA == 0)begin
//         PHASE_CNT <= 4'd0;
//     end
//     else begin
//         if(DDS_DATA_VALID == 0) begin
//             PAHSE_CNT <= 0;
//         end
//         else if(PHASE_CNT < PHASE_INCREASE_SEL) begin
//             PAHSE_CNT <= PHASE_CNT + 1;
//         end
//         else if(PHASE_CNT == PHASE_INCREASE_SEL) begin
//             PHASE_CNT <= 4'd0;
//         end
//     end
// end

dds_compiler_3 DDS_3(
    .aclk   (GCLK),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (DDS_DATA),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid (DDS_DATA_VALID),
    .s_axis_phase_tdata  ({8'd0,PHASE_INCREASE_NUM}),
    .s_axis_phase_tvalid (MODULE_ENA)
);

endmodule