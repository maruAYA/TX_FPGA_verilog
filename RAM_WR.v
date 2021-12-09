//********READ DATA FROM PS AND MAPPING DATA FOR DA*********//
// Read data from PS wrapper(axis_data, axis_tvalid, axis_tlast). A port is used for reading operation.
//Reading at the frequency of 1/4 input frequency. From the top of ram to the axis_tlast address. Data read is stored in I_buffer and Q_buffer. 
//Mapping procedure takes 8 time circles. Giving two mapping IP cores and name them as I_m and Q_m. Every 4 times send the binary code into the free mapping core. 
//Writing operation start when tvalid == 1 and tlast == 0. When tvalid is pulled to 1 when was 0 before, meaning for the start of writing procedure.
module RAM_WR(  
    input   PL_READY,
    output  reg [15:0]  I_buffer,//Read buffer from mapping module
    output  reg [15:0]  Q_buffer,
    output  reg  RAM_READY,//Connect to PS wrapper's axis_S_ready
    input   [1:0]   axis_data_keep,//Data valid signal, not conern
    input   axis_data_valid,
    input   axis_tlast,
    input   [31:0]  axis_data,
    
    input   reset,
    input   ram_clk,//400MHz
    input   clk,//200MHz
    input   [3:0] SEQ_NUM,
    input   FIFO_EMPTY,

    output  reg [7:0]   s_axis_data,
    output  reg s_axis_tkeep,
    output  reg s_axis_tlast,
    output  reg s_axis_tvalid,
    input   s_axis_tready
);
reg [15:0]  Add_W;//Writing operation address
reg WEa;//B port->Read port enable
reg [15:0]  Add_R;
reg [4:0]   Add_Unfold;//Address for unfold module
reg [2:0]   R_CNT;//Core counter for operating the whole system
wire [15:0] COM_buffer;//Common buffer, read data from unfold stream data ram. 
reg [15:0]  Add_last;
reg PL_READY_PRE;
wire [31:0] First_buffer;//First stage buffer, unfold stream data
// reg [1:0] SUB_RAM_SEL_CNT;
// reg [1:0] SUB_RAM_ADD_R;

// reg [1:0]   SUB_RAM_0_ADD_W;
// reg [1:0]   SUB_RAM_1_ADD_W;
// reg [1:0]   SUB_RAM_2_ADD_W;
// reg [1:0]   SUB_RAM_3_ADD_W;




initial begin
    RAM_READY <= 0;
    Add_W <= 16'b0;
    Add_R <= 16'b0;
    Add_last <= 16'd65535;
    WEa <= 0;
    I_buffer <= 16'b0;
    Q_buffer <= 16'b0;
    R_CNT <= 3'b0;
    Add_Unfold <= 5'd0;
    PL_READY_PRE <= 0;
end


//Read data from ram-part.2 READING AND PATH DIVIDING


//*******Diving the process into two parrel cirlce, every 4 times of counting change the runing circl.********//

always @(posedge clk) begin
    if(reset == 1) begin
        I_buffer <= 16'b0;
        Q_buffer <= 16'b0;
    end 
    else begin
        if(R_CNT == 3'b0) begin
            I_buffer <= COM_buffer;
        end
        else if(R_CNT == 3'b100) begin 
            Q_buffer <= COM_buffer;
        end
    end
end


//******Every 4 times of counter core ram send one unfold data out for mapping. After all bytes of the 4B data are unfolded(Add_Unfold == 5'b31), read the next 4B data from the*******//
//******first stage buffer*******//
always @(posedge clk) begin
    if(reset == 1) begin
        Add_Unfold <= 5'd0;
    end
    else begin
        case({PL_READY})
            1'b1: begin
                if(Add_R == 16'd65535 || Add_R == Add_last) begin
                    if(Add_Unfold == 5'd31) begin
                        if(R_CNT == 3'b111) begin    
                            Add_R <= 16'b0;
                            R_CNT <= 3'b0;
                            Add_Unfold <= 5'd0;
                        end
                        else begin  
                                R_CNT <= R_CNT + 1;
                        end
                    end
                    else begin
                        if(R_CNT == 3'b111)begin
                            R_CNT = 3'b0;
                            Add_Unfold = Add_Unfold + 1;
                        end
                        else begin
                            R_CNT <= R_CNT + 1;
                        end
                    end
                end
                else begin
                    if(Add_Unfold != 5'd31) begin
                        if(R_CNT == 3'b111) begin
                            Add_Unfold <= Add_Unfold + 1;
                            R_CNT <= 3'b0;
                        end
                        else if(R_CNT == 3'b011) begin
                            Add_Unfold <= Add_Unfold + 1;
                            R_CNT <= R_CNT + 1;
                        end 
                        else begin
                            R_CNT <= R_CNT + 1;
                        end
                    end
                    else begin
                        if(R_CNT == 3'b111) begin
                            Add_Unfold <= 5'd0;
                            R_CNT <= 3'b0;
                            Add_R <= Add_R + 1;
                        end
                        else begin
                            R_CNT <= R_CNT + 1;
                        end
                    end
                end
            end
            default begin
            end
        endcase
    end
end

//write data into RAM
always @(posedge clk) begin
    if(reset != 1) begin
        case({RAM_READY, axis_data_valid})
        2'b11: begin
            if(axis_tlast == 1 || Add_W == 16'd65535) begin
                Add_W <= Add_W + 1;
                Add_last <= Add_W + 1;
            end
            else begin
                if(PL_READY_PRE == 0) begin // Initiallize the sysyem when transfer begin
                    Add_W <= 16'b0;
                end
                else begin
                    WEa <= 1;
                    Add_W <= Add_W + 1;
                end
            end
        end
        default: begin
            WEa <= 0;
            Add_W <= 16'b0;
        end
        endcase
        PL_READY_PRE <= PL_READY;
    end
end
//Write control
always @(posedge clk) begin
    if(reset == 1) begin
        RAM_READY <= 0;
    end
    else begin
        if(Add_R == 16'd0 && axis_data_valid == 1) begin
            RAM_READY <= 1;    
        end
        else begin
            RAM_READY <= 0;

        end
    end
end

always @(posedge clk) begin
    s_axis_data <= {2'b0, FIFO_EMPTY, RAM_READY, SEQ_NUM};
    if(reset == 1) begin
        s_axis_tkeep <= 0;
        s_axis_tlast <= 0;
        s_axis_tvalid <= 0;
    end
    else begin
        case ({RAM_READY, s_axis_tready, s_axis_tlast, s_axis_tvalid})
        4'b1100: begin
            s_axis_tkeep <= 1;
            s_axis_tlast <= 1;
            s_axis_tvalid <= 1;
        end
        4'b1111: begin
            s_axis_tkeep <= 1;
            s_axis_tlast <= 0;
            s_axis_tvalid <= 0;
        end
        default: begin
            s_axis_tkeep <= 0;
            s_axis_tlast <= 0;
            s_axis_tvalid <= 0;
        end
        endcase
    end
end


// COM_buffer->common buffer, first-state buffer receiving data from ram and sending into I buffer or Q buffer
blk_mem_gen_0 RAM(
     .clka   (~clk), 
     .ena    (PL_READY),
     .wea    (axis_data_valid),  
     .addra  (Add_W), 
     .dina   (axis_data),
     .clkb   (~clk), 
     .addrb  (Add_R),
     .doutb  (First_buffer),
     .enb       (PL_READY)
);


CUSTOM_RAM CORE_RAM(
    .clk    (~clk),
    .ena    (PL_READY),
    .axis_data  (First_buffer),
    .reset  (reset),
    .axis_unfold_data   (COM_buffer),
    .ADD_R  (Add_Unfold)
);


endmodule
