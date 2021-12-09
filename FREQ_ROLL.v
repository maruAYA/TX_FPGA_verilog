module  FREQ_ROLL(
    input   reset,
    input   GCLK,
    input   MODULE_ENA,
    output [31:0]  DDS_OUT,
    output  reg [7:0]   I_ROM_ADD,
    output reg DDS_DATA_VALID
);
wire [15:0] Idata;
wire [15:0] Qdata;
assign  DDS_OUT = MODULE_ENA ? {Qdata, Idata}:32'd0;
//reg [7:0] I_ROM_ADD;
reg [7:0] Q_ROM_ADD;
initial begin
    I_ROM_ADD <= 8'd0;
    Q_ROM_ADD <= 8'd0;
    DDS_DATA_VALID <= 0;
end

always @(posedge GCLK) begin
    if(reset == 1) begin
        DDS_DATA_VALID <= 0;
        I_ROM_ADD <= 8'd0;
        Q_ROM_ADD <= 8'd0;
    end
    else begin
        DDS_DATA_VALID <= 1;
        if(I_ROM_ADD == 8'd240 || Q_ROM_ADD == 8'd240) begin
            I_ROM_ADD <= 8'd0;
            Q_ROM_ADD <= 8'd0;
        end
        else begin
            I_ROM_ADD <= I_ROM_ADD + 1;
            Q_ROM_ADD <= Q_ROM_ADD + 1;
        end
    end
end
blk_mem_gen_2   IROM(
    .clka   (GCLK),
    .ena    (MODULE_ENA),
    .addra  (I_ROM_ADD),
    .douta  (Idata)
);
blk_mem_gen_3   QROM(
    .clka   (GCLK),
    .ena    (MODULE_ENA),
    .addra  (Q_ROM_ADD),
    .douta  (Qdata)
);
endmodule