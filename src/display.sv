// Preprocessed calculation for converting 100MHz to 5Khz
`define MHZ100_TO_KHZ5  (28'd100_000_000 / 28'd5_000)

//////////////////////////////////////////
// Modules:                             //
//      display                         //
//          clock_gen                   //
//          mux_led                     //
//          bcd_to_hex                  //
//////////////////////////////////////////

module clock_gen

(   input        reset,
    input        clock_100Mhz,
    output logic clock_5KHz   );

    localparam divisor = `MHZ100_TO_KHZ5;

    logic [15:0] counter;

    // Increment counter and when at max, toggle clock
    always_ff @(posedge clock_100Mhz or posedge reset) begin
        if(reset) begin
            counter     <= 0;
            clock_5KHz  <= 0;
        end 
        else begin
            if (counter == divisor) begin 
                clock_5KHz <= ~clock_5KHz;
            end
            else begin 
                counter    <= counter + 1;                
            end
        end
    end

endmodule

module mux_led

(   input        clock, reset,
    input        [7:0] leds [7:0],
    output logic [7:0] sel_led,
    output       [7:0] led_value  );

    logic [2:0] select;

    // Increment mux select
    always_ff @(posedge clock, posedge reset) begin 
        if (reset) begin 
            select  <= 0;
            sel_led <= 0;
        end
        else begin 
            select  <= select + 1;
            sel_led <= (8'hFF) & ~(1 << select); 
        end
    end

    // Combinationally set LED value
    assign led_value = leds[select];

endmodule

module bcd_to_hex

(   input        [3:0] bcd,
    output logic [7:0] segment );

    always_comb begin 
        case (bcd)
            0:  segment = 8'b10001000;
            1:  segment = 8'b11101101;
            2:  segment = 8'b10100010;
            3:  segment = 8'b10100100;
            4:  segment = 8'b11000101;
            5:  segment = 8'b10010100;
            6:  segment = 8'b10010000;
            7:  segment = 8'b10101101;
            8:  segment = 8'b10000000;
            9:  segment = 8'b10000100;
            10: segment = 8'b10100000;
            11: segment = 8'b11010000;
            12: segment = 8'b11110010;
            13: segment = 8'b11100000;
            14: segment = 8'b10010010;
            15: segment = 8'b10010011;
        endcase
    end

endmodule

module display

(   input        clock, reset,
    input  [3:0] bcds [7:0],
    output [7:0] sel_led,
    output [7:0] led_value      );

    logic       clock_5KHz;
    logic [7:0] leds [7:0];

    clock_gen CLOCK_GENERATOR
    (
        .clock_5KHz     (clock_5KHz),
        .clock_100Mhz   (clock),
        .reset          (reset)
    );

    mux_led MULTIPLEXER_LEDS
    (
        .clock          (clock),
        .reset          (reset),
        .leds           (leds),
        .sel_led        (sel_led),
        .led_value      (led_value)
    );

    genvar g;
    generate
        for (g=0; g<8; g++) begin
            bcd_to_hex BCD_TO_HEX ( .bcd(bcds[g]), .segment(leds[g]) );
        end
    endgenerate

endmodule