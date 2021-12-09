//*********MAPPING INPUT DATA TO COS SERIES**********//
//When ram is ready, mapping input data into cos series. Using 2 rom cores for 1 & 0. 
module  mappingQ(
    input   clk,
    input   [15:0] FRAME_DATA,//Idata or Qdata from RAM_WR
    output  reg [15:0]  Mapped_data,//Mapped data from rom 
    input   reset,
    input   RAM_READY, 
    input   [2:0]   CNT
);
reg [3:0] Add_1;
reg [3:0] Add_0;
wire [15:0] Buffer_1;
wire [15:0] Buffer_0;
initial begin
    Mapped_data <= 16'b0;
    Add_1 <= 3'b0;
    Add_0 <= 3'b0;
end

always @(posedge clk) begin
    if(RAM_READY == 1 && FRAME_DATA[3'd0] == 1'b0) begin
        if(CNT == 3'd3) begin
            Add_0 <= 0;
        end
        else begin
            Add_0 <= Add_0 + 1;
        end
        Mapped_data <= Buffer_0;
    end
    else begin
        if(RAM_READY == 1 && FRAME_DATA[3'd0] == 1'b1) begin
            if(CNT == 3'd3) begin
                Add_1 <= 0;
            end
        else begin
            Add_1 <= Add_1 + 1;
        end
        Mapped_data <= Buffer_1;
        end
    end
end

blk_mem_gen_3 ROM_0(
    .clka   (~clk), 
    .addra  (Add_0), 
    .douta  (Buffer_0),
    .ena    (RAM_READY)  
);

blk_mem_gen_4 ROM_1(
    .clka   (~clk),
    .addra  (Add_1),
    .douta  (Buffer_1),
    .ena    (RAM_READY)
);
endmodule