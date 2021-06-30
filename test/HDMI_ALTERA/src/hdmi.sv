// Implementation of HDMI Spec v1.4a
// By Sameer Puri https://github.com/sameer
//
// ALTLVDS_TX megafunction & INV_TMDS#
// V1.0 -> ALTLVDS_TX uses it's own internal PLL
// added by Brian Guralnick on Jan 6, 2021
//

module hdmi
#(
    // Set to 0 to activate the external clk_pixel_x5 input.
    // Set to 1 to automatically internally generate a PLL for the TMDS TXD clock.
    // Using 1 will usually use an additional PLL if Quartus cannot merge the required clock with an existing external PLL.
    parameter bit HDMI_SERTX_INTERNAL_PLL = 1'b0,

    // Tells the ALTLVDS_TX serializer what the approximate source pixel clock is.  Only needs to be within 1 MHz.
    // Only used when USE_EXT_PLLx5 is disabled.
    // You may lie here and state your pixel clock is only 740mbps or 640mbps allowing compile for -7/-8 Cyclone FPGAs
    // while still truly running a 74.25MHz pixel clock, 742.5mbps when using either LVDS or emulated LVDS_E_3R IO standard.
    parameter int HDMI_SERTX_PIXEL_MBPS = 270,

    // Invert the TMDS channels, 0 thru 2, and 3 for the clock channel.
    // IE - Swaps the +&- pins of the LVDS output pins for ease of PCB routing.
    parameter bit INV_TMDS0 = 1'b0,
    parameter bit INV_TMDS1 = 1'b0,
    parameter bit INV_TMDS2 = 1'b0,
    parameter bit INV_TMDS3 = 1'b0,


    // Defaults to 640x480 which should be supported by almost if not all HDMI sinks.
    // See README.md or CEA-861-D for enumeration of video id codes.
    // Pixel repetition, interlaced scans and other special output modes are not implemented (yet).
    parameter int VIDEO_ID_CODE = 2,

    // Defaults to minimum bit lengths required to represent positions.
    // Modify these parameters if you have alternate desired bit lengths.
    //parameter int BIT_WIDTH = VIDEO_ID_CODE < 4 ? 10 : VIDEO_ID_CODE == 4 ? 11 : 12,
    //parameter int BIT_HEIGHT = VIDEO_ID_CODE == 16 ? 11: 10,
    parameter int BIT_WIDTH  = 13, // Note that HDL compilers automatically remove unused/inactive
    parameter int BIT_HEIGHT = 12, // logic registers during compile & fitting.

    // A true HDMI signal sends auxiliary data (i.e. audio, preambles) which prevents it from being parsed by DVI signal sinks.
    // HDMI signal sinks are fortunately backwards-compatible with DVI signals.
    // Enable this flag if the output should be a DVI signal. You might want to do this to reduce resource usage or if you're only outputting video.
    parameter bit DVI_OUTPUT = 1'b0,


    // **All parameters below matter ONLY IF you plan on sending auxiliary data (DVI_OUTPUT == 1'b0)**

    // Specify the refresh rate in Hz you are using for audio calculations
    parameter real VIDEO_REFRESH_RATE = 59.94,

    // As specified in Section 7.3, the minimal audio requirements are met: 16-bit or more L-PCM audio at 32 kHz, 44.1 kHz, or 48 kHz.
    // See Table 7-4 or README.md for an enumeration of sampling frequencies supported by HDMI.
    // Note that sinks may not support rates above 48 kHz.
    parameter int AUDIO_RATE = 48000,

    // Defaults to 16-bit audio, the minmimum supported by HDMI sinks. Can be anywhere from 16-bit to 24-bit.
    parameter int AUDIO_BIT_WIDTH = 16,

    // Some HDMI sinks will show the source product description below to users (i.e. in a list of inputs instead of HDMI 1, HDMI 2, etc.).
    // If you care about this, change it below.
    parameter bit [8*8-1:0] VENDOR_NAME = {"Unknown", 8'd0}, // Must be 8 bytes null-padded 7-bit ASCII
    parameter bit [8*16-1:0] PRODUCT_DESCRIPTION = {"FPGA", 96'd0}, // Must be 16 bytes null-padded 7-bit ASCII
    parameter bit [7:0] SOURCE_DEVICE_INFORMATION = 8'h00 // See README.md or CTA-861-G for the list of valid codes
)
(
    //input logic clk_pixel_x10,
    input logic clk_pixel_x5,
    input logic clk_pixel,
    input logic clk_audio,
    input logic clk_audio_ena,
    input logic [23:0] rgb,
    input logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word [1:0],

    // These outputs go to your HDMI port
    output logic [3:0] tmds_tx,
    
    // All outputs below this line stay inside the FPGA
    // They are used (by you) to pick the color each pixel should have
    // i.e. always_ff @(posedge pixel_clk) rgb <= {8'd0, 8'(cx), 8'(cy)};
    output logic [BIT_WIDTH-1:0] cx = 0,
    output logic [BIT_HEIGHT-1:0] cy = 0,
    
    // the screen is at the bottom right corner of the frame, namely:
    // frame_width = screen_start_x + screen_width
    // frame_height = screen_start_y + screen_height
    output logic [BIT_WIDTH-1:0] frame_width,
    output logic [BIT_HEIGHT-1:0] frame_height,
    output logic [BIT_WIDTH-1:0] screen_width,
    output logic [BIT_HEIGHT-1:0] screen_height,
    output logic [BIT_WIDTH-1:0] screen_start_x,
    output logic [BIT_HEIGHT-1:0] screen_start_y
);

localparam int NUM_CHANNELS = 3;
logic hsync;
logic vsync;

// See CEA-861-D for more specifics formats described below.
generate
    case (VIDEO_ID_CODE)
        1:
        begin
            assign frame_width = 800;
            assign frame_height = 525;
            assign screen_width = 640;
            assign screen_height = 480;
            assign hsync = ~(cx >= 16 && cx < 16 + 96);
            assign vsync = ~(cy >= 10 && cy < 10 + 2);
            end
        2, 3:
        begin
            assign frame_width = 858;
            assign frame_height = 525;
            assign screen_width = 720;
            assign screen_height = 480;
            assign hsync = ~(cx >= 16 && cx < 16 + 62);
            assign vsync = ~(cy >= 9 && cy < 9 + 6);
            end
        4:
        begin
            assign frame_width = 1650;
            assign frame_height = 750;
            assign screen_width = 1280;
            assign screen_height = 720;
            assign hsync = cx >= 110 && cx < 110 + 40;
            assign vsync = cy >= 5 && cy < 5 + 5;
        end
        16:
        begin
            assign frame_width = 2200;
            assign frame_height = 1125;
            assign screen_width = 1920;
            assign screen_height = 1080;
            assign hsync = cx >= 88 && cx < 88 + 44;
            assign vsync = cy >= 4 && cy < 4 + 5;
        end
        34:  // 1080p @ 29.97Hz
        begin
            assign frame_width = 2200;
            assign frame_height = 1125;
            assign screen_width = 1920;
            assign screen_height = 1080;
            assign hsync = cx >= 88 && cx < 88 + 44;
            assign vsync = cy >= 4 && cy < 4 + 5;
        end
        17, 18:
        begin
            assign frame_width = 864;
            assign frame_height = 625;
            assign screen_width = 720;
            assign screen_height = 576;
            assign hsync = ~(cx >= 12 && cx < 12 + 64);
            assign vsync = ~(cy >= 5 && cy < 5 + 5);
        end
        19:
        begin
            assign frame_width = 1980;
            assign frame_height = 750;
            assign screen_width = 1280;
            assign screen_height = 720;
            assign hsync = cx >= 440 && cx < 440 + 40;
            assign vsync = cy >= 5 && cy < 5 + 5;
        end
        97, 107:
        begin
            assign frame_width = 4400;
            assign frame_height = 2250;
            assign screen_width = 3840;
            assign screen_height = 2160;
            assign hsync = cx >= 176 && cx < 176 + 88;
            assign vsync = cy >= 8 && cy < 8 + 10;
        end

        969:     // Brian Special, 16:9 960p, = 4x 480p - 108MHz
        begin
            assign frame_width = 1716;
            assign frame_height = 1050;
            assign screen_width = 1440;
            assign screen_height = 960;
            assign hsync = ~(cx >= 32 && cx < 32 + 124);
            assign vsync = ~(cy >= 18 && cy < 18 + 6);
        end
        964:     // Brian Special,  4:3 960p, = 4x VGA640x480 - 94.5MHz
        begin
            assign frame_width = 1518;
            assign frame_height = 1038;
            assign screen_width = 1280;
            assign screen_height = 960;
            assign hsync = (cx >= 24 && cx < 24 + 96);
            assign vsync = (cy >= 14 && cy < 14 + 6);
        end
        965:     // Vesa  4:3 960p, = 4x VGA 640x480 - 108MHz vesa 60hz
        begin
            assign frame_width   = 1800;
            assign frame_height  = 1000;
            assign screen_width  = 1280;
            assign screen_height = 960;
            assign hsync = (cx >= 96 && cx < 96 + 112);
            assign vsync = (cy >= 1 && cy < 1 + 3);
        end
        1024:    // Vesa  1280x1024 - 108MHz
        begin
            assign frame_width   = 1688;
            assign frame_height  = 1066;  // 1066=60Hz vesa, 1067=59.96.
            assign screen_width  = 1280;
            assign screen_height = 1024;
            assign hsync = (cx >= 48 && cx < 48 + 114);
            assign vsync = (cy >= 1  && cy < 1 + 3);
        end
        1085:    // Brian Special 1080p50hz reduced blanking - 121.5MHz
        begin
            assign frame_width   = 2160;
            assign frame_height  = 1125;
            assign screen_width  = 1920;
            assign screen_height = 1080;
            assign hsync = cx >= 76 && cx < 76 + 38;
            assign vsync = cy >= 3 && cy < 3 + 5;
        end
        1084:    // Brian Special 1080p50hz super reduced blanking - 108MHz
        begin
            assign frame_width   = 2020;
            assign frame_height  = 1090;
            assign screen_width  = 1920;
            assign screen_height = 1080;
            assign hsync = (cx >= 32 && cx < 32 + 16);
            assign vsync = (cy >= 1 && cy < 1 + 3);
        end


    endcase
    assign screen_start_x = frame_width - screen_width;
    assign screen_start_y = frame_height - screen_height;
endgenerate

// Wrap-around pixel position counters indicating the pixel to be generated by the user in THIS clock and sent out in the NEXT clock.
always_ff @(posedge clk_pixel)
begin
    cx <= cx == frame_width-1'b1 ? (BIT_WIDTH)'(0) : cx + 1'b1;
    cy <= cx == frame_width-1'b1 ? cy == frame_height-1'b1 ? (BIT_HEIGHT)'(0) : cy + 1'b1 : cy;
end

// See Section 5.2
logic video_data_period = 1;
always_ff @(posedge clk_pixel)
    video_data_period <= cx >= screen_start_x && cy >= screen_start_y;

logic [2:0] mode = 3'd1;
logic [23:0] video_data = 24'd0;
logic [5:0] control_data = 6'd0;
logic [11:0] data_island_data = 12'd0;

generate
    if (!DVI_OUTPUT)
    begin: true_hdmi_output
        logic video_guard = 0;
        logic video_preamble = 0;
        always_ff @(posedge clk_pixel)
        begin
            video_guard <= cx >= screen_start_x - 2 && cx < screen_start_x && cy >= screen_start_y;
            video_preamble <= cx >= screen_start_x - 10 && cx < screen_start_x - 2 && cy >= screen_start_y;
        end

        // See Section 5.2.3.1
        int max_num_packets_alongside;
        logic [4:0] num_packets_alongside;
        always_comb
        begin
            max_num_packets_alongside = (screen_start_x /* VD period */ - 2 /* V guard */ - 8 /* V preamble */ - 12 /* 12px control period */ - 2 /* DI guard */ - 2 /* DI start guard */ - 8 /* DI premable */) / 32;
            if (max_num_packets_alongside > 18)
                num_packets_alongside = 5'd18;
            else
                num_packets_alongside = 5'(max_num_packets_alongside);
        end

        logic data_island_period_instantaneous;
        assign data_island_period_instantaneous = num_packets_alongside > 0 && cx >= 10 && cx < 10 + num_packets_alongside * 32;
        logic packet_enable;
        assign packet_enable = data_island_period_instantaneous && 5'(cx + 22) == 5'd0;

        logic data_island_guard = 0;
        logic data_island_preamble = 0;
        logic data_island_period = 0;
        always_ff @(posedge clk_pixel)
        begin
            data_island_guard <= num_packets_alongside > 0 && ((cx >= 8 && cx < 10) || (cx >= 10 + num_packets_alongside * 32 && cx < 10 + num_packets_alongside * 32 + 2));
            data_island_preamble <= num_packets_alongside > 0 && /* cx >= 0 && */ cx < 8;
            data_island_period <= data_island_period_instantaneous;
        end

        // See Section 5.2.3.4
        logic [23:0] header;
        logic [55:0] sub [3:0];
        logic video_field_end;
        assign video_field_end = cx == frame_width - 1'b1 && cy == frame_height - 1'b1;
        logic [4:0] packet_pixel_counter;
        localparam real VIDEO_RATE = (VIDEO_ID_CODE == 1 ? 25.2E6
            : VIDEO_ID_CODE == 2 || VIDEO_ID_CODE == 3 ? 27E6
            : VIDEO_ID_CODE == 4 ? 74.25E6
            : VIDEO_ID_CODE == 16 ? 148.5E6
            : VIDEO_ID_CODE == 17 || VIDEO_ID_CODE == 18 ? 27E6
            : VIDEO_ID_CODE == 19 ? 74.25E6
            : VIDEO_ID_CODE == 34 ? 74.25E6
            : VIDEO_ID_CODE == 97 || VIDEO_ID_CODE == 107 ? 594E6
            : VIDEO_ID_CODE == 964 ? 94.5E6
            : VIDEO_ID_CODE == 965 ? 108E6
            : VIDEO_ID_CODE == 969 ? 108E6
            : VIDEO_ID_CODE == 1024 ? 108E6
            : VIDEO_ID_CODE == 1085 ? 121.5E6
            : VIDEO_ID_CODE == 1084 ? 108E6
            : 0) * (VIDEO_REFRESH_RATE == 59.94 ? 1000.0/1001.0 : 1); // https://groups.google.com/forum/#!topic/sci.engr.advanced-tv/DQcGk5R_zsM
        packet_picker #(
            .VIDEO_ID_CODE(VIDEO_ID_CODE),
            .VIDEO_RATE(VIDEO_RATE),
            .AUDIO_RATE(AUDIO_RATE),
            .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH),
            .VENDOR_NAME(VENDOR_NAME),
            .PRODUCT_DESCRIPTION(PRODUCT_DESCRIPTION),
            .SOURCE_DEVICE_INFORMATION(SOURCE_DEVICE_INFORMATION)
        ) packet_picker (.clk_pixel(clk_pixel), .clk_audio(clk_audio), .clk_audio_ena(clk_audio_ena), .video_field_end(video_field_end), .packet_enable(packet_enable), .packet_pixel_counter(packet_pixel_counter), .audio_sample_word(audio_sample_word), .header(header), .sub(sub));
        logic [8:0] packet_data;
        packet_assembler packet_assembler (.clk_pixel(clk_pixel), .data_island_period(data_island_period), .header(header), .sub(sub), .packet_data(packet_data), .counter(packet_pixel_counter));


        always_ff @(posedge clk_pixel)
        begin
            mode <= data_island_guard ? 3'd4 : data_island_period ? 3'd3 : video_guard ? 3'd2 : video_data_period ? 3'd1 : 3'd0;
            video_data <= rgb;
            control_data <= {{1'b0, data_island_preamble}, {1'b0, video_preamble || data_island_preamble}, {vsync, hsync}}; // ctrl3, ctrl2, ctrl1, ctrl0, vsync, hsync
            data_island_data[11:4] <= packet_data[8:1];
            data_island_data[3] <= cx != screen_start_x;
            data_island_data[2] <= packet_data[0];
            data_island_data[1:0] <= {vsync, hsync};
        end
    end
    else // DVI_OUTPUT = 1
    begin
        always_ff @(posedge clk_pixel)
        begin
            mode <= video_data_period;
            video_data <= rgb;
            control_data <= {4'b0000, {vsync, hsync}}; // ctrl3, ctrl2, ctrl1, ctrl0, vsync, hsync
        end
    end
endgenerate

// All logic below relates to the production and output of the 10-bit TMDS code.
logic [9:0] tmds [NUM_CHANNELS:0] ;     /* verilator public_flat */
assign      tmds[3] = 10'b0000011111 ;  // Assign the fixed bit pattern for the TMDS[3] clock output.

genvar i;
generate
    // TMDS code production.
    for (i = 0; i < NUM_CHANNELS; i++)
    begin: tmds_gen
        tmds_channel #(.CN(i)) tmds_channel (.clk_pixel(clk_pixel), .video_data(video_data[i*8+7:i*8]), .data_island_data(data_island_data[i*4+3:i*4]), .control_data(control_data[i*2+1:i*2]), .mode(mode), .tmds(tmds[i]));
    end

endgenerate


//***********************************************************
//*** Use Altera's altlvds_tx serializer.                ***
//***********************************************************
//
HDMI_serializer_altlvds #( .HDMI_SERTX_INTERNAL_PLL(HDMI_SERTX_INTERNAL_PLL),    .HDMI_SERTX_PIXEL_MBPS(HDMI_SERTX_PIXEL_MBPS),
                           .INV_TMDS0(INV_TMDS0),   .INV_TMDS1(INV_TMDS1),       .INV_TMDS2(INV_TMDS2), .INV_TMDS3(INV_TMDS3)
) HDMI_serializer_altlvds( .clk_pixel(clk_pixel),   .clk_pixel_x5(clk_pixel_x5), .tmds_par_in(tmds),    .tmds_ser_out(tmds_tx) );

//********************************************************** Resource @ https://www.xilinx.com/support/documentation/user_guides/ug471_7Series_SelectIO.pdf
//*** Use Xilinx OSERDESE2 serializer.                   *** Page 169 table 3-11, supports 10:1 in DDR mode.
//**********************************************************
//
//HDMI_serializer_OSERDESE2 #( .HDMI_SERTX_INTERNAL_PLL(HDMI_SERTX_INTERNAL_PLL),    .HDMI_SERTX_PIXEL_MBPS(HDMI_SERTX_PIXEL_MBPS),
//                             .INV_TMDS0(INV_TMDS0),   .INV_TMDS1(INV_TMDS1),       .INV_TMDS2(INV_TMDS2), .INV_TMDS3(INV_TMDS3)
//) HDMI_serializer_OSERDESE2( .clk_pixel(clk_pixel),   .clk_pixel_x5(clk_pixel_x5), .tmds_par_in(tmds),    .tmds_ser_out(tmds_tx) );


endmodule
