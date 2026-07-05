`timescale 1ns / 1ps
module top(
    input clk,
    input reset,
    input [1:0] mode,
    input start_stop,
    input clear,
    input load_timer,
    output reg [6:0] seg,
    output reg [3:0] an
);

// ============================================================
// 1Hz clock enable (NOT a divided clock - avoids TIMING-17)
// ============================================================
reg [26:0] count;
reg en_1hz;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        count  <= 0;
        en_1hz <= 0;
    end else if (count == 27'd99_999_999) begin
        count  <= 0;
        en_1hz <= 1;
    end else begin
        count  <= count + 1;
        en_1hz <= 0;
    end
end

// ============================================================
// Edge detection for buttons (all run on 100MHz clk)
// ============================================================
reg ss_prev, cl_prev, ld_prev;
wire ss_edge = start_stop & ~ss_prev;
wire cl_edge = clear      & ~cl_prev;
wire ld_edge = load_timer & ~ld_prev;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ss_prev <= 0;
        cl_prev <= 0;
        ld_prev <= 0;
    end else begin
        ss_prev <= start_stop;
        cl_prev <= clear;
        ld_prev <= load_timer;
    end
end

// ============================================================
// Clock mode (MM:SS)
// ============================================================
reg [5:0] sec, min;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        sec <= 0;
        min <= 0;
    end else if (mode == 2'b00 && en_1hz) begin
        if (sec == 6'd59) begin
            sec <= 0;
            min <= (min == 6'd59) ? 6'd0 : min + 1;
        end else begin
            sec <= sec + 1;
        end
    end
end

// ============================================================
// Stopwatch (counts up, start/stop toggle, clear resets)
// ============================================================
reg sw_run;
reg [5:0] sw_sec;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        sw_run <= 0;
        sw_sec <= 0;
    end else if (mode == 2'b01) begin
        if (cl_edge) begin
            sw_run <= 0;
            sw_sec <= 0;
        end else if (ss_edge) begin
            sw_run <= ~sw_run;
        end else if (sw_run && en_1hz) begin
            sw_sec <= (sw_sec == 6'd59) ? 6'd0 : sw_sec + 1;
        end
    end
end

// ============================================================
// Timer (countdown, load presets to 30s, start/stop toggle)
// ============================================================
reg timer_run;
reg [5:0] timer_sec;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        timer_run <= 0;
        timer_sec <= 0;
    end else if (mode == 2'b10) begin
        if (ld_edge) begin
            timer_sec <= 6'd30;
            timer_run <= 0;
        end else if (ss_edge) begin
            timer_run <= ~timer_run;
        end else if (timer_run && en_1hz) begin
            if (timer_sec == 6'd0)
                timer_run <= 0;
            else
                timer_sec <= timer_sec - 1;
        end
    end
end

// ============================================================
// Display MUX select
// ============================================================
reg [5:0] disp_sec, disp_min;
always @(*) begin
    case (mode)
        2'b00:   begin disp_sec = sec;       disp_min = min; end
        2'b01:   begin disp_sec = sw_sec;    disp_min = 6'd0; end
        2'b10:   begin disp_sec = timer_sec; disp_min = 6'd0; end
        default: begin disp_sec = 6'd0;      disp_min = 6'd0; end
    endcase
end

// ============================================================
// BCD conversion (no % or / - purely combinational with if-else)
// ============================================================
reg [3:0] s0, s1, m0, m1;
always @(*) begin
    // Seconds units digit
    if      (disp_sec >= 50) s1 = 4'd5;
    else if (disp_sec >= 40) s1 = 4'd4;
    else if (disp_sec >= 30) s1 = 4'd3;
    else if (disp_sec >= 20) s1 = 4'd2;
    else if (disp_sec >= 10) s1 = 4'd1;
    else                     s1 = 4'd0;
    s0 = disp_sec - (s1 * 10);

    // Minutes units digit
    if      (disp_min >= 50) m1 = 4'd5;
    else if (disp_min >= 40) m1 = 4'd4;
    else if (disp_min >= 30) m1 = 4'd3;
    else if (disp_min >= 20) m1 = 4'd2;
    else if (disp_min >= 10) m1 = 4'd1;
    else                     m1 = 4'd0;
    m0 = disp_min - (m1 * 10);
end

// ============================================================
// Refresh counter for display multiplexing (~381Hz per digit)
// ============================================================
reg [16:0] refresh;
always @(posedge clk or posedge reset) begin
    if (reset) refresh <= 0;
    else       refresh <= refresh + 1;
end
wire [1:0] digit = refresh[16:15];

// ============================================================
// 7-segment output
// ============================================================
reg [3:0] bcd_sel;
always @(*) begin
    case (digit)
        2'b00: begin an = 4'b1110; bcd_sel = s0; end
        2'b01: begin an = 4'b1101; bcd_sel = s1; end
        2'b10: begin an = 4'b1011; bcd_sel = m0; end
        2'b11: begin an = 4'b0111; bcd_sel = m1; end
    endcase
end

// ============================================================
// 7-segment decoder (active LOW: seg[0]=a, seg[6]=g)
// ============================================================
always @(*) begin
    case (bcd_sel)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

endmodule
