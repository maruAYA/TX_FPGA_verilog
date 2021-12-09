module  CUSTOM_RAM(
    input [4:0] ADD_R,
    input [31:0] axis_data,
    input ena,
    input clk,
    input reset,
    output reg [15:0] axis_unfold_data
);
integer i;
integer j;

reg [15:0] CORE_RAM [31:0];
initial begin
    for(i=0;i <= 31; i = i + 1) begin
        CORE_RAM[i] <= 16'b0;
    end
    axis_unfold_data <= 16'd0;
end

always @(posedge clk) begin
    if(reset == 1) begin
    for(i=0;i <= 31; i = i + 1) begin
        CORE_RAM[i] <= 16'b0;
    end
    end
    else if(ena == 1)begin
        for(j=0; j <= 31; j = j + 1) begin
            CORE_RAM[j] = {15'd0, axis_data[31-j]};
        end
    end
end

always @(posedge clk) begin
    if(reset == 1) begin
        axis_unfold_data <= 16'd0;
    end
    else if(ena == 1) begin
        axis_unfold_data <= CORE_RAM[ADD_R];    
    end
end

endmodule