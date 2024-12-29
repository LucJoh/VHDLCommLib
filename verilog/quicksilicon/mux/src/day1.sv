// A simple mux

module day1 (
    input   wire [7:0]    a_i,
    input   wire [7:0]    b_i,
    input   wire          sel_i,
    output  reg [7:0]    y_o
    );

    always @(*) begin
        if (sel_i == 0) begin
            assign y_o = a_i;
        end else begin	
            assign y_o = b_i;
        end
    end

endmodule
