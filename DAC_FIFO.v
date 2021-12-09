module  DAC_FIFO(
    input   GCLK, //FIFO MAIN CLK
    input   [15:0]  Idata,
    input   [15:0]  Qdata,
    output  [15:0]  Idata_OUT,
    output  [15:0]  Qdata_OUT,
// ******CLK used for control********* //
    input   DA_DATA_CLK,//DA's clk
    input   DDS_CLK,//DDS used clk
    
    input   reset,
    input   DDS_DATA_VALID,
    input   DA_EN
);
wire [15:0]  I_RAM_OUT;
wire [15:0]  Q_RAM_OUT;
reg [9:0] I_RAM_W_ADDR;
reg [9:0] I_RAM_R_ADDR;  
reg [9:0] Q_RAM_W_ADDR;
reg [9:0] Q_RAM_R_ADDR;

initial begin
    I_RAM_R_ADDR <= 10'd0;
    I_RAM_W_ADDR <= 10'd0;
    Q_RAM_R_ADDR <= 10'd0;
    Q_RAM_W_ADDR <= 10'd0;
end
//**************//
// I path FIFO  //
blk_mem_gen_0 I_RAM(
    .clka   (GCLK), 
    .ena    (DDS_DATA_VALID),
    .wea    (DDS_DATA_VALID),
    .addra  (I_RAM_W_ADDR),
    .dina   (Idata),
    .clkb   (GCLK),
    .enb    (DA_EN),
    .addrb  (I_RAM_R_ADDR),
    .doutb  (Idata_OUT),
    .rstb (reset)
);
always @(posedge GCLK) begin
    if(reset == 1 || DDS_DATA_VALID == 0 || DA_EN == 0) begin
        I_RAM_R_ADDR <= 0;
        I_RAM_W_ADDR <= 0;
    end
    else begin
        if(I_RAM_R_ADDR == 10'hfff) begin
            I_RAM_R_ADDR <= 10'd0;
        end
        else if(DDS_DATA_VALID == 1 && DDS_CLK == 1) begin
            I_RAM_W_ADDR <= I_RAM_W_ADDR + 1;
        end
        if(I_RAM_R_ADDR == 10'hfff) begin
            I_RAM_W_ADDR <= 10'd0;
        end
        else if(DA_DATA_CLK == 1) begin
            I_RAM_R_ADDR <= I_RAM_R_ADDR + 1;
        end
    end
end

//**************//
// Q path FIFO  //
blk_mem_gen_1 Q_RAM(
    .clka   (GCLK), 
    .ena    (DDS_DATA_VALID),
    .wea    (DDS_DATA_VALID),
    .addra  (Q_RAM_W_ADDR),
    .dina   (Qdata),
    .clkb   (GCLK),
    .enb    (DA_EN),
    .addrb  (Q_RAM_R_ADDR),
    .doutb  (Qdata_OUT),
    .rstb (reset)
);
always @(posedge GCLK) begin
    if(reset == 1 || DDS_DATA_VALID == 0 || DA_EN == 0) begin
        Q_RAM_R_ADDR <= 0;
        Q_RAM_W_ADDR <= 0;
    end
    else begin
        if(Q_RAM_R_ADDR == 10'hfff) begin
            Q_RAM_R_ADDR <= 10'd0;
        end
        else if(DDS_DATA_VALID == 1 && DDS_CLK == 1) begin
            Q_RAM_W_ADDR <= Q_RAM_W_ADDR + 1;
        end
        if(Q_RAM_W_ADDR == 10'hfff) begin
            Q_RAM_W_ADDR <= 10'd0;
        end
        else if(DA_DATA_CLK == 1) begin
            Q_RAM_R_ADDR <= Q_RAM_R_ADDR + 1;
        end  
    end
end

endmodule