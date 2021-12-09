module  TQPM(
    output [5:0]  TQPM_OUT
);

always @(posedge GCLK) begin
    TQPM_OUT <= 6'd111111;
end
endmodule


