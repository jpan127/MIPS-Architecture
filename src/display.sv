// Preprocessed calculation for converting 100MHz to 5Khz
`define MHZ100_TO_KHZ5  (28'd100_000_000 / 28'd5_000)

//////////////////////////////////////////
// Modules:                             //
//      display                         //
//          clock_gen                   //
//          mux_led                     //
//          bcd_to_hex                  //
//////////////////////////////////////////

module debouncer

(   input  clock, reset,
    input  button,
    output debounced    );

    localparam max = (2 ** 16) - 1;
    logic [16-1:0] history;

    always_ff @(posedge clock, posedge reset) begin 
        if (reset) begin 
            history <= 0;    
        end
        else begin 
            history <= { button, history[16-1:1] };
        end
    end

    assign debounced = (history == max);

endmodule

module clock_gen

(   input        reset,
    input        clock_100MHz,
    output logic clock_5KHz   );

    localparam divisor = 16'd20_000; //`MHZ100_TO_KHZ5;

    logic [15:0] counter;

    // Increment counter and when at max, toggle clock
    always_ff @(posedge clock_100MHz or posedge reset) begin
        if (reset) begin
            counter     <= 0;
            clock_5KHz  <= 0;
        end 
        else begin
            // Always increment
            counter <= counter + 1;
            // Toggle clock when counter reaches max
            if (counter == divisor) begin 
                clock_5KHz <= ~clock_5KHz;
                counter    <= 0;
            end
        end
    end

endmodule

module clock_controller

(   input        clock_100MHz, reset, button,
    output logic db_button,
    output logic clock_5KHz                   );

    clock_gen CLOCK_GENERATOR
    (
        .reset          (reset),
        .clock_100MHz   (clock_100MHz),
        .clock_5KHz     (clock_5KHz)
    );

    debouncer DEBOUNCER
    (
        .clock          (clock_5KHz),
        .reset          (reset),
        .button         (button),
        .debounced      (db_button)
    );

endmodule

module mux_led

(   input              clock, reset,
    input        [7:0] leds [7:0],
    output logic [7:0] sel_led,
    output logic [7:0] led_value  );

    logic [2:0] select;

    // Increment mux select
    always_ff @(posedge clock, posedge reset) begin
        select <= (reset) ? (0) : (select + 1);
    end

    // Switch led
    assign sel_led   = (8'hFF) & ~(1 << select);
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

module display_controller

(   input        clock, reset,
    input  [3:0] bcds [7:0],
    output [7:0] sel_led,
    output [7:0] led_value      );

    logic [7:0] leds [7:0];

    mux_led MULTIPLEXER_LEDS
    (
        .clock      (clock),
        .reset      (reset),
        .leds       (leds),
        .sel_led    (sel_led),
        .led_value  (led_value)
    );

    genvar g;
    generate
        for (g=0; g<8; g++) begin
            bcd_to_hex BCD_TO_HEX ( .bcd(bcds[g]), .segment(leds[g]) );
        end
    endgenerate

endmodule