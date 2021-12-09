module ADRF(
    input   ADRF_CONTROL,
    input   GCLK, //ADRF SPI CLK
    output  reg ADRF_CS,//ADRFCS
    output  reg     ADRF_READY,
    output  reg     ADRF_SPI_OUT,
    input   reset
); 

reg ADRF_ASSIS;
    reg [4:0] count;
    reg [7:0] PC;
    reg [23:0] ADRF_INSTR;

initial begin
        count <= 5'd0;
        ADRF_READY <= 0;
        PC <= 8'h00;
        ADRF_INSTR <= 23'b0;
        ADRF_SPI_OUT <= 1'b0;
        ADRF_CS <= 1;
        ADRF_ASSIS <= 0;
end

always @(posedge GCLK) begin
    if(reset == 1) begin
        count <= 5'd0;
        PC <= 8'h00;
        ADRF_SPI_OUT <= 1'b0;
        ADRF_CS <= 1;
        ADRF_ASSIS <= 0;
    end
    else begin
        if({PC, count} >= 13'b0000000100000 && ADRF_CS == 1 && ADRF_CONTROL == 1) begin
            ADRF_CS <= 0;
        end
        if(ADRF_READY == 1) begin
            ADRF_CS <= 1;
        end
        else begin
        if({PC, count} <= 13'b0000000100000) begin
            if(ADRF_CONTROL == 1 && count == 5'd23) begin
                PC <= PC + 1;
                count <= 5'd0;
                ADRF_SPI_OUT <= ADRF_INSTR[5'd0];
            end
            else if(ADRF_CONTROL == 1 && count < 5'd23) begin
            ADRF_SPI_OUT <= ADRF_INSTR[5'd23-count];
            count <= count + 1;
            end
            ADRF_CS<= 1;
        end
            if(ADRF_READY == 0 && ADRF_ASSIS == 1 && ADRF_CONTROL == 1) begin
                if(count < 5'd23 && {PC, count} >= 13'b0000000100000) begin
                    ADRF_SPI_OUT <= ADRF_INSTR[5'd23-count];
                    count <= count + 1;
                    ADRF_ASSIS <= 0;
                end
            end
            else if(ADRF_CONTROL == 1 && count == 5'd0 && ADRF_READY == 0 && ADRF_CS == 0 && PC > 8'b00000001) begin
                ADRF_CS <= 1;
                ADRF_ASSIS <= 1;
            end
            else if(ADRF_CONTROL == 1 && count == 5'd23 && ADRF_READY == 0 && ADRF_CS == 0 && ADRF_ASSIS == 0) begin
                PC <= PC + 1;
                count <= 5'd0;
                ADRF_SPI_OUT <= ADRF_INSTR[5'd0];
            end
            else if(ADRF_CONTROL == 1 && count < 5'd23 && ADRF_READY == 0 && ADRF_CS == 0 && ADRF_ASSIS == 0) begin
                ADRF_SPI_OUT <= ADRF_INSTR[5'd23-count];
                count <= count + 1;
            end
        end
    end
end

always @(posedge GCLK) begin
    if(reset == 1) begin
        ADRF_READY <= 0;
        ADRF_INSTR <= 23'b0;
    end
    else begin
    if(count == 5'd23 && ADRF_CONTROL == 1) begin
        case(PC)
        // 8'h00:  ADRF_INSTR <= 24'h000000;//00
        // 8'h01:  ADRF_INSTR <= 24'h02F67F;//01
        // 8'h02:  ADRF_INSTR <= 24'h040820;//02
        // 8'h03:  ADRF_INSTR <= 24'h060000;//03
        // 8'h04:  ADRF_INSTR <= 24'h080064;//04
        // 8'h05:  ADRF_INSTR <= 24'h20F67F;//10
        // 8'h06:  ADRF_INSTR <= 24'h400C26;//20
        // 8'h07:  ADRF_INSTR <= 24'h42000A;//21
        // 8'h08:  ADRF_INSTR <= 24'h442A03;//22
        // 8'h09:  ADRF_INSTR <= 24'h600000;//30
        // 8'h0A:  ADRF_INSTR <= 24'h621101;//31
        // 8'h0B:  ADRF_INSTR <= 24'h640900;//32
        // 8'h0C:  ADRF_INSTR <= 24'h660000;//33
        // 8'h0D:  ADRF_INSTR <= 24'h800010;//40
        // 8'h0E:  ADRF_INSTR <= 24'h84000E;//42
        // 8'h0F:  ADRF_INSTR <= 24'h860000;//43
        // 8'h10:  ADRF_INSTR <= 24'h900000;//45
        // 8'h11:  ADRF_INSTR <= 24'h9814B4;//49
        // 8'h12:  ADRF_READY <= 1;
        // Attemping to nulling LO
        8'h00:  ADRF_INSTR <= 24'h000000;//00
        8'h01:  ADRF_INSTR <= 24'h02F67F;//01
        8'h02:  ADRF_INSTR <= 24'h04081A;//02
        8'h03:  ADRF_INSTR <= 24'h060000;//03
        8'h04:  ADRF_INSTR <= 24'h080064;//04
        8'h05:  ADRF_INSTR <= 24'h20F67F;//10
        8'h06:  ADRF_INSTR <= 24'h400C26;//20
        8'h07:  ADRF_INSTR <= 24'h42000A;//21
        8'h08:  ADRF_INSTR <= 24'h442A03;//22
        8'h09:  ADRF_INSTR <= 24'h600000;//30
        8'h0A:  ADRF_INSTR <= 24'h621101;//31
        8'h0B:  ADRF_INSTR <= 24'h64092D;//32
        8'h0C:  ADRF_INSTR <= 24'h66141E;//33 I:20 Q:30
        8'h0D:  ADRF_INSTR <= 24'h800010;//40
        8'h0E:  ADRF_INSTR <= 24'h84000E;//42
        8'h0F:  ADRF_INSTR <= 24'h860000;//43
        8'h10:  ADRF_INSTR <= 24'h900000;//45
        8'h11:  ADRF_INSTR <= 24'h9814B4;//49
        8'h12:  ADRF_READY <= 1;
    endcase
    end
    end
end

endmodule