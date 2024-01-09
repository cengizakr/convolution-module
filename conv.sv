// Cengiz ÇAKIR



module convolution #(parameter logic [1:0][1:0] filter = '{'{1, 0}, '{0, 1}}) (
  input logic clk_i,      // input clock
  input logic rst_ni,     // logic-0 asserted asynch reset
  input logic valid_i,    // asserted when pixels are loaded into the module
  input logic [7:0] pixel_i, // pixel values loaded
  output logic valid_o,   // asserted when the convolution is done
  output logic [7:0] pixel_o, // convolved pixel values
  output logic [31:0] state_s
);
  
  // Internal memory for input pixels
  logic [7:0] image[639:0][359:0];

  // Internal memory for convolved pixels
  logic [7:0] convolved_image[319:0][179:0];
  
  // Variables to indicate pixel indices

  logic [15:0] x=0;
  logic [15:0] y=0;

  // Result of convolution
  logic [7:0] result;
  
  // Intermediate variables 
  logic zero_x =0; //indicates new line in image
  logic inc_y =0;
  logic zero_y =0;
  
  
  
  
  // Defining the state types 
  // I used 3 states
  typedef enum logic [1:0] {TAKE_IMG, CONVOLVE, OUT_IMG, IDLE}
  statetype;
  statetype state;
  statetype nextstate;
  
  
 // State register
always_ff @(negedge rst_ni, posedge clk_i)
begin
    // If reset is asserted, the state machine should turn to the idle state
    if (rst_ni) begin
        state <= IDLE;
        nextstate <= IDLE;
    end
    else begin
        state <= nextstate;
    end
end

//counter
always_ff@(posedge clk_i) begin

    if(state_s == 1 || state_s == 3) begin
        if(!zero_x) 
            x<= x+1;
        else
            x<=0;
        if(inc_y)
            y<=y+1;
        else if (zero_y) begin
            y <= 0;
        end
    end
    
    else if (state_s == 2) begin 
        if(!zero_x) 
            x<= x+2;
        else
            x<=0;
        if(inc_y)
            y<=y+2;
        else if (zero_y) begin
            y <= 0;
        end
    end 
    
    
end

// Combinational Logic
  always_comb begin 
   case(state)
    TAKE_IMG: 
    begin
        zero_x =0;
        inc_y =0;
        zero_y =0;
        
        if(valid_i)
        begin
            state_s = 3'd1;
            //store the image byte into inner memory
            image[x][y] = pixel_i;
            
            if(x>638) begin
                zero_x = 1; 
                if(y == 359) begin
                    zero_y =1 ;
                    nextstate = CONVOLVE;
                end
                else begin
                inc_y =1;
            end 
            
        end
    end
    end
    
    CONVOLVE:
    begin
        zero_x =0;
        inc_y =0;
        zero_y =0;
        valid_o = 0;
        state_s = 3'd2;
        
        result = (image[x][y] * filter[0][0] +
        image[x+1][y] * filter[0][1] +
        image[x][y+1] * filter[1][0] +
        image[x+1][y+1] * filter[1][1]) / 4;
        
        // Store result in convolved_image memory
        convolved_image[x/2][y/2] = result;
        
        if(x>637) begin
            zero_x = 1; 
            if(y > 358) begin
                zero_y =1 ;
                nextstate = OUT_IMG;
            end
            else begin
                inc_y =1;
            end    
        end
    end
    
    OUT_IMG:
    begin
        zero_x =0;
        inc_y =0;
        zero_y =0;
        
        valid_o <= 1; // Signal that tells convolution is done
        state_s <= 3'd3;
        pixel_o = convolved_image[x][y];
        
        if(x>318) begin
        zero_x = 1; 
        if(y > 178) begin
            zero_y =1 ;
            state_s = 30;
            nextstate = IDLE;
        end
        else begin
            inc_y =1;
        end    
    end

    end
    
// Idle Case
    IDLE: 
    begin
    zero_x = 1; 
    zero_y = 1;
    state_s =3'b000;
    if(valid_i) begin
        image[x][y] = pixel_i;
        nextstate = TAKE_IMG;
        pixel_o = 32;
    end
    else begin
        valid_o = 0;
        nextstate = IDLE;
    end 
    end
    
// Default Case    
    default:
        nextstate = IDLE;
    endcase
  end

endmodule
