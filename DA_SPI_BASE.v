//From the data sheet DA_CS is optional in One master-slave condition, so in this module DA_CS is deleted and directly input SPI into the chip
//Considering setting DA_CS high for 8 DA_SCLK reset the inner time machine, so this test is needed 
//2021.11.7
module DA_SPI_BASE(
    input   GCLK,
    input   reset,
    input   DA_CONTROL,//Differ from DA_CONTROL in DA_SPI_RE
    input   CLM_LOCK,
    output reg  DA_SPI,
    output  DA_SCLK,
    output reg  DA_CS,//Setting to low after the system is steady
    output reg  DA_READY,//assign to DA_EN
    output reg [7:0]  DA_PC,
    output reg [7:0]  DA_INSTR,
    output reg [2:0]  DA_CNT  
);
assign  DA_SCLK = GCLK & (CLM_LOCK) & (~DA_CS);
initial begin
    DA_PC <= 8'd0;
    DA_INSTR <= 8'h02;
    DA_CNT <= 3'd1;
    DA_SPI <= 0;
    DA_CS <= 1;
    DA_READY <= 0;
end
//DA counter controlling
always @(posedge GCLK) begin
    if(reset == 1 || CLM_LOCK == 0) begin
        DA_CNT <= 3'd1;
        DA_PC <= 8'd0;
    end
    else begin
        if(DA_READY == 0 && DA_CS == 0) begin
            DA_CNT <= DA_CNT + 1;
            if(DA_CNT == 3'd6) begin
                DA_PC <= DA_PC + 1;
            end
        end
    end
end

//DA PC controlling
always @(posedge GCLK) begin
    if(reset == 1 || CLM_LOCK == 0) begin
        DA_INSTR <= 8'd0;
        DA_READY <= 0;
    end 
    else if(DA_CS == 0) begin
        case (DA_PC)
        8'h0:       DA_INSTR <= 8'b00000000;//0x0
        8'h1:       DA_INSTR <= 8'h02;
        8'h2:       DA_INSTR <= 8'b00000001;//0x1
        8'h4:       DA_INSTR <= 8'hC0;
        8'h3:       DA_INSTR <= 8'h31;
        8'h5:       DA_INSTR <= 8'b00000010;//0x2
        8'h7:       DA_INSTR <= 8'h0C;
        8'h6:       DA_INSTR <= 8'h0;
        8'h8:       DA_INSTR <= 8'b00000011; //0x3
        8'h0C:      DA_INSTR <= 8'h00;
        8'h0B:      DA_INSTR <= 8'h0;
        8'h0A:      DA_INSTR <= 8'h0;
        8'h09:      DA_INSTR <= 8'h80;
        8'h0D:      DA_INSTR <= 8'b00000100;//0x4
        8'h10:      DA_INSTR <= 8'hFF;//Intend for Pll band auto.
        8'h0F:      DA_INSTR <= 8'b10110011;//N1 = 01 N2 = 10
        8'h0E:      DA_INSTR <= 8'b01101111;
        8'h11:      DA_INSTR <= 8'b00000101;//0x5
        8'h13:      DA_INSTR <= 8'hF9;
        8'h12:      DA_INSTR <= 8'h01;
        8'h14:      DA_INSTR <= 8'b00000110;//0x6
        8'h16:      DA_INSTR <= 8'h0;
        8'h15:      DA_INSTR <= 8'h0;
        8'h17:      DA_INSTR <= 8'b00000111;//0x7
        8'h19:      DA_INSTR <= 8'hF9;
        8'h18:      DA_INSTR <= 8'h01;
        8'h1A:      DA_INSTR <= 8'b00001000;//0x8
        8'h1C:      DA_INSTR <= 8'h00;
        8'h1B:      DA_INSTR <= 8'h00;
        8'h1D:      DA_INSTR <= 8'b00001001;//0x9
        8'h1F:      DA_INSTR <= 8'h00;
        8'h1E:      DA_INSTR <= 8'h00;
        8'h20:      DA_INSTR <= 8'b00001010;//0xA
        8'h24:      DA_INSTR <= 8'h80;
        8'h23:      DA_INSTR <= 8'hC3;
        8'h22:      DA_INSTR <= 8'hC9;
        8'h21:      DA_INSTR <= 8'h01;
        8'h25:      DA_INSTR <= 8'b00001011;//0xB
        8'h29:      DA_INSTR <= 8'h0;
        8'h28:      DA_INSTR <= 8'h0;
        8'h27:      DA_INSTR <= 8'h0;
        8'h26:      DA_INSTR <= 8'h0;
        8'h2A:      DA_INSTR <= 8'b00001100;//0xC
        8'h2D:      DA_INSTR <= 8'h80;
        8'h2C:      DA_INSTR <= 8'h0;
        8'h2B:      DA_INSTR <= 8'h01;
        8'h2E:      DA_INSTR <= 8'b00001101;//0xD
        8'h32:      DA_INSTR <= 8'h00;
        8'h31:      DA_INSTR <= 8'h00;
        8'h30:      DA_INSTR <= 8'h00;
        8'h2F:      DA_INSTR <= 8'h00;
        8'h33:      DA_INSTR <= 8'h84; //0x04
        8'h36:      DA_INSTR <= 8'b0;
        8'h35:      DA_INSTR <= 8'h0;
        8'h34:      DA_INSTR <= 8'h0; 
            default: 
                DA_READY <= 1;
        endcase
    end
end
//DA_CS control
always @(posedge GCLK) begin
    if(reset == 1) begin
        DA_CS <= 1;
    end
    else begin
        if(DA_CONTROL == 1 && DA_CS == 1 && DA_READY == 0) begin
            DA_CS <= DA_READY;
        end
        else if(DA_READY == 1) begin
            DA_CS <= 1;
        end
    end
end
//DA SPI_OUT control
always @(posedge GCLK) begin
    if(reset == 1 || CLM_LOCK == 0) begin
        DA_SPI <= 0;
    end
    else begin
        if(DA_READY == 0 && DA_CS == 0) begin
            DA_SPI <= DA_INSTR[3'd7 - DA_CNT];
        end
    end
end
endmodule