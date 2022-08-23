// Initial I2S_transmitter code, untested, by nockieboy August 2022.

module I2S_transmitter #(

    parameter int           BITS     = 16,  // Audio width, can be anything from 8 to 24
    parameter bit           INV_BCLK = 0    // When set, make I2S_BCLK fall during valid data

)(

    //Inputs
    input  logic            clk_in,         // High speed clock
    input  logic            clk_i2s,        // 50/50 duty cycle serial audio clock to feed through
    input  logic            clk_i2s_pulse,  // Should strobe for one clk_in cycle at the beginning of each new clk_i2s
    input  logic            sample_in,      // Optional input to reset the sample position.  This should either be tied to GND or only pulse once every 64 'clk_i2s_pulse's
    input  logic [BITS-1:0] DAC_Left,       // Left channel digital audio sampled once every 'sample_pulse' output
    input  logic [BITS-1:0] DAC_Right,      // Right channel digital audio sampled once every 'sample_pulse' output

    //Outputs
    output logic            sample_pulse,   // Pulses once when a new stereo sample is taken from the DAC_Left/Right inputs.  Hint: once every 64 clk_i2s_pulse's
    output logic            I2S_BCLK,       // I2S serial bit clock output (SCLK), basically the clk_i2s input in the correct phase
    output logic            I2S_WCLK,       // I2S !left / right output (LRCLK)
    output logic            I2S_DATA        // Serial data output

);

    logic             [5:0] I2S_counter       = 0 ;
    logic        [BITS-1:0] DAC_right_buffer  = 0 ;
    logic        [BITS-1:0] DAC_serial_buffer = 0 ;

    assign I2S_WCLK = I2S_counter[5]            ; // Hard wire the I2S Word Clock to the I2S_counter MSB.
    assign I2S_DATA = DAC_serial_buffer[BITS-1] ; // Hard wire the I2S serial data bits to the MSB of the serial data buffer.

    always_ff @( posedge clk_in ) begin
        
        I2S_BCLK <= clk_i2s ^ !INV_BCLK ; // Optionally invert clk_i2s for correct I2S_BCLK phase

        // Manage I2S pulse counter and serialisation
        if ( clk_i2s_pulse ) begin

            if (sample_in) I2S_counter  <= 6'd0            ; // Optional clear to I2S counter position '0'
            else           I2S_counter  <= I2S_counter + 1 ;

            sample_pulse <= ( I2S_counter == 0 ) ; // Pulse the output reference sample clock.

            // Strobe sample_pulse once every 64 cycles & sample appropriate L/R input
            if ( I2S_counter == 0 ) begin

                DAC_right_buffer   <= DAC_Right             ; // Keep a copy of the Right channel data to be transmitted during the second half.
                                                              // This was done to make sure both left and right channel data are captured in parallel on the same clock.
                DAC_serial_buffer  <= DAC_Left              ; // Transfer the left channel for immediate transmission.

            end else if ( I2S_counter == 32 ) begin

                DAC_serial_buffer <= DAC_right_buffer       ; // Transfer the right channel's sample for immediate transmission.
            
            end else begin

                DAC_serial_buffer <= DAC_serial_buffer << 1 ; // Left shift the serial out data.

            end

        end // if ( clk_i2s_pulse ) begin

    end // always

endmodule