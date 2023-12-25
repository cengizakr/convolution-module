module tb_convolution;

  // Parameters
  localparam logic [1:0][1:0] filter = '{'{1, 0}, '{0, 1}};

  // Internal memory for input pixels
  logic [7:0] test_image[230399:0] ;

  int x_i =0;
  
  string filename = "output_bak.txt";
  int file_handle;
  
  // Inputs
  logic clk;
  logic rst_n=0 ;
  logic valid_i =0;
  logic valid_i_c=0;
  logic [7:0] pixel_i;
  logic [31:0]state_s;
  

  // Outputs
  logic valid_o ;
  logic [7:0] pixel_o;

  // Instantiate the convolution module
  convolution #(filter) uut (
    .clk_i(clk),
    .rst_ni(rst_n),
    .valid_i(valid_i),
    .pixel_i(pixel_i),
    .valid_o(valid_o),
    .pixel_o(pixel_o),
    .*
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    file_handle = $fopen(filename, "w");
    rst_n =1;
    #3; 
    rst_n =0;
    $readmemh("output_hex.hex", test_image);
    #5;
    valid_i_c =1;
  end
  
  always_comb begin 
   if (x_i > 230400) begin
         valid_i =0;
      end
   else begin 
   valid_i = valid_i_c;
   end 
  end
  
 
  
  // Clocked always block to update pixel_i on each clock cycle
  always_ff @(posedge clk) begin 
    if (valid_i == 1) begin
      // Update pixel_i from the test_image array
      pixel_i <= test_image[x_i];
      // Increment x 
      x_i <= x_i + 1;

    end
    
    else if (valid_o) begin 
          $fwrite(file_handle, pixel_o, "\n");
    end  
    if(state_s == 30) begin 
            $fclose(file_handle);
    end
        
  end
 

endmodule
