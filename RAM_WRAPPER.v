module RAM_WRAPPER(
    input   [1:0]   axis_data_keep,
    input   axis_data_valid,
    input   axis_tlast,
    input   [31:0]  axis_data,
    input   PL_READY,


    input   clk,
    input   ram_clk,

    output  [15:0]  Idata,
    output  [15:0]  Qdata,
    input   reset,
    input   FIFO_EMPTY,
    input   [3:0] SEQ_NUM,

//axis-stream bus as slave, write data into dma to give status to processor
    output  [7:0]   s_axis_data,
    output  s_axis_tkeep,
    output  s_axis_tvalid,
    output  s_axis_tlast,
    input   s_axis_tready
);
wire RAM_READY;
wire [15:0] I_buffer;
wire [15:0] Q_buffer;

RAM_WR  MAIN_RAM(
    .PL_READY   (PL_READY),
    .axis_data_keep (axis_data_keep),
    .axis_data  (axis_data),
    .axis_data_valid    (axis_data_valid),
    .axis_tlast (axis_tlast),
    
    .RAM_READY  (RAM_READY),
    .clk        (clk),
    .I_buffer   (I_buffer),
    .Q_buffer   (Q_buffer),
    .reset      (reset),
    .SEQ_NUM    (SEQ_NUM),
    .ram_clk    (ram_clk),

    .s_axis_data    (s_axis_data),
    .s_axis_tkeep   (s_axis_tkeep),
    .s_axis_tlast   (s_axis_tlast),
    .s_axis_tready  (s_axis_tready),
    .s_axis_tvalid  (s_axis_tvalid)
);

mappingI IMAP(
    .CNT  (R_CNT),
    .FRAME_DATA  (I_buffer),
    .Mapped_data    (Idata),
    .RAM_READY      (PL_READY),
    .clk            (~clk),
    .ram_clk        (ram_clk)
);

mappingQ QMAP(
    .CNT  (R_CNT),
    .FRAME_DATA  (Q_buffer),
    .Mapped_data    (Qdata),
    .RAM_READY      (PL_READY),
    .clk            (~clk),
    .ram_clk        (ram_clk)
);

endmodule