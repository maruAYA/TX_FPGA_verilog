// SPI generation for ad9788
// Reconstructed from previous DASPI.v built in 2021.4.30
// Using Larger DA_CNT to create buffer state, which replace the previous solutio of using other signal to generate and determine the buffer state
//2021.11.5
//Modified in 2021.11.7, correct the byte length and the CS logic. Previous release divide the information into block of 8 bites, 
//and divide each with CS pulling high, which is not desired in this design. Current release is not recommended before DA_SPI_BASE is tested
module DA_SPI_RE(
    output DA_SCLK,
    input   reset,
    input   PC_CONTROL,
    input   GCLK,
    input   CLM_LOCK,

    output reg  DA_CS,
    output reg  DA_SPI_OUT,
    output  reg DA_READY,
    output  reg [39:0]   DA_INSTR,
    output  reg [7:0]   DA_PC,
    output  reg [5:0]   DA_CNT,
    output  reg [5:0] DA_TAR_CNT
);
reg CNT_FLAG;//Flag for count complete;
reg PC_REC;
initial begin
    PC_REC <= 0;
    DA_CS <= 1;
    DA_SPI_OUT <= 1;
    DA_INSTR <= 8'd0;
    DA_READY <= 0;
    DA_CNT <= 6'd16;
    DA_PC <= 32'hff;
    DA_TAR_CNT <= 6'd16;
    CNT_FLAG <= 1;
end
assign DA_SCLK = GCLK & (~CNT_FLAG | ~DA_CS) & CLM_LOCK;
// assign  DA_SCLK = GCLK;
//Counter Controlling
always @(posedge GCLK) begin
    if(reset == 1  || CLM_LOCK == 0 || DA_READY == 1) begin
        DA_CNT <= 6'd16;
        DA_PC <= 8'hff;
        CNT_FLAG <= 1;
        PC_REC <= 0;
    end
    else if(DA_READY == 0) begin
        if(DA_CNT == DA_TAR_CNT && PC_CONTROL == 1 && CNT_FLAG == 1) begin
            DA_CNT <= 6'd0;
            CNT_FLAG <= 0;
        end
        // else if(DA_CNT == 3'd0 && PC_CONTROL == 0 && PC_REC == 1) begin
        //     DA_CNT <= DA_CNT;
        // end
        else if(DA_CNT < DA_TAR_CNT && CNT_FLAG == 0 && PC_CONTROL == 0) begin
            DA_CNT <= DA_CNT + 1;
        end
        if(DA_CNT == (DA_TAR_CNT) && CNT_FLAG == 1 && PC_REC == 0 && PC_CONTROL == 1) begin
            DA_PC <= DA_PC + 1;
        end
        if(DA_CNT == (DA_TAR_CNT - 1)) begin
            CNT_FLAG <= 1;
        end
        PC_REC <= PC_CONTROL;
    end
end

//Chip Select Controlling
always @(negedge GCLK) begin
    if(reset == 1  || CLM_LOCK == 0 || DA_READY == 1) begin
        DA_CS <= 1;
    end
    else if(DA_READY == 0) begin
        if(DA_PC != 8'hff) begin
            if(DA_CNT == DA_TAR_CNT) begin
                DA_CS <= 1;
            end
            else if(PC_CONTROL == 0 && PC_REC == 1) begin
                DA_CS <= 0;
            end
        end
        else begin
            DA_CS <= 1;
        end
    end
end
//Output Clock Controlling
// always @(posedge GCLK) begin
//     if(reset == 1) begin
//         DA_SCLK <= 0;
//     end
//     else begin
//         if(DA_CS == 0) begin
//             DA_SCLK <= ~DA_SCLK;
//         end
//     end
// end
//Data output address Controlling
//2021.11.14 Add a soft reset instruction
always @(posedge GCLK) begin
    if(reset == 1  || CLM_LOCK == 0) begin
        DA_INSTR <= 8'h00;
        DA_READY <= 0;
    end
    else if(DA_READY == 0) begin
        case (DA_PC)
        8'h0:       DA_INSTR <= 16'h0012;//W0x0-reset 2021.11.14
        8'h01:       DA_INSTR <= 16'h0006;//W0x0
        8'h02:       DA_INSTR <= 24'h010180;//W0x1
        8'h03:       DA_INSTR <= 24'h02000C;//0x2
        8'h04:       DA_INSTR <= 40'h0380000400; //0x3
        8'h05:      DA_INSTR <= 32'h046FB3FF;//0x4
        // // 8'h10:      DA_INSTR <= 8'hFF;//Intend for Pll band auto.
        // // 8'h0F:      DA_INSTR <= 8'b10110011;//N1 = 01 N2 = 10
        // // 8'h0E:      DA_INSTR <= 8'b01101111;
        // 8'h5:      DA_INSTR <= 24'h0501F9;//0x5
        // // 8'h13:      DA_INSTR <= 8'hF9;
        // // 8'h12:      DA_INSTR <= 8'h01;
        // 8'h6:      DA_INSTR <= 24'h060000;//0x6
        // 8'h7:      DA_INSTR <= 24'h0701F9;//0x7
        // // 8'h19:      DA_INSTR <= 8'hF9;
        // // 8'h18:      DA_INSTR <= 8'h01;
        // 8'h8:       DA_INSTR <= 24'h080000;//0x8
        // // 8'h1C:      DA_INSTR <= 8'h00;
        // // 8'h1B:      DA_INSTR <= 8'h00;
        // 8'h9:      DA_INSTR <= 24'h090000;//0x9
        // // 8'h1F:      DA_INSTR <= 8'h00;
        // // 8'h1E:      DA_INSTR <= 8'h00;
        8'h06:      DA_INSTR <= 40'h0A80000000;//0xA
        // // 8'h24:      DA_INSTR <= 8'h0;
        // // 8'h23:      DA_INSTR <= 8'h0;
        // // 8'h22:      DA_INSTR <= 8'h0;
        // // 8'h21:      DA_INSTR <= 8'h10;
        // 8'h0B:      DA_INSTR <= 40'h0B00000000;//0xB
        // // 8'h29:      DA_INSTR <= 8'h0;
        // // 8'h28:      DA_INSTR <= 8'h0;
        // // 8'h27:      DA_INSTR <= 8'h0;
        // // 8'h26:      DA_INSTR <= 8'h0;
        // 8'h0C:      DA_INSTR <= 32'h0C010080;//0xC
        // // 8'h2D:      DA_INSTR <= 8'h80;
        // // 8'h2C:      DA_INSTR <= 8'h0;
        // // 8'h2B:      DA_INSTR <= 8'h01;
        // 8'h0D:      DA_INSTR <= 40'h0D00000000;//0xD
        // // 8'h32:      DA_INSTR <= 8'h00;
        // // 8'h31:      DA_INSTR <= 8'h00;
        // // 8'h30:      DA_INSTR <= 8'h00;
        // // 8'h2F:      DA_INSTR <= 8'h00;
        8'h07:      DA_INSTR <= 24'h890000;
        // 8'h33:      DA_INSTR <= 8'h89; //0x04
        // 8'h34:      DA_INSTR <= 8'b0;
        // 8'h35:      DA_INSTR <= 8'h0;
        8'h08:      DA_INSTR <= 40'h8A00000000;
        8'hff:      DA_INSTR <= 8'h0;//Empty
        default:    begin
                    DA_READY <= 1;
                    end
        endcase
    end
end
//Data Width counter Controlling
always @(posedge GCLK) begin
    if(reset == 1 || CLM_LOCK == 0) begin
        DA_TAR_CNT <= 64'h10;
    end
    else begin
        case (DA_PC)
            8'h00: DA_TAR_CNT <= 64'd16;
            8'h01: DA_TAR_CNT <= 64'd16;
            8'h02: DA_TAR_CNT <= 64'd24;
            8'h03:  DA_TAR_CNT <= 64'd24;
            8'h04:  DA_TAR_CNT <= 64'd40;
            8'h05:  DA_TAR_CNT <= 64'd32;
            // 8'h05:  DA_TAR_CNT <= 64'd24;
            // 8'h06:  DA_TAR_CNT <= 64'd24;
            // 8'h07:  DA_TAR_CNT <= 64'd24;
            // 8'h08:  DA_TAR_CNT <= 64'd24;
            // 8'h09:  DA_TAR_CNT <= 64'd24;
            8'h06:  DA_TAR_CNT <= 64'd40;
            // 8'h0B:  DA_TAR_CNT <= 64'd40;
            // 8'h0C:  DA_TAR_CNT <= 64'd32;
            // 8'h0D:  DA_TAR_CNT <= 64'd40;
            8'h07:  DA_TAR_CNT <= 64'd24;
            8'h08:  DA_TAR_CNT <= 64'd40;
            default: 
                DA_TAR_CNT <= 64'd16;
        endcase
    end
end
//spi data out controlling
always @(posedge GCLK) begin
    if(reset == 1  || CLM_LOCK == 0)begin
        DA_SPI_OUT <= 0; 
    end
    else if(DA_READY == 0) begin
        DA_SPI_OUT <= DA_INSTR[DA_TAR_CNT - 1 - DA_CNT];
    end
end
endmodule