module FREQ_SINGLE(
    input   reset,
    input   GCLK,
    input   MODULE_ENA,
    output  DDS_DATA_VALID,
    output [31:0] DDS_DATA,
    output  [31:0]  DDS_OUT
);
wire DDS_DATA_VALID;
assign  DDS_OUT = (MODULE_ENA) ? DDS_DATA:32'bz;

dds_compiler_0 DDS(
    .aclk   (GCLK),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (DDS_DATA),    // output wire [15 : 0] m_axis_data_tdata
    .m_axis_data_tvalid (DDS_DATA_VALID)
);

endmodule