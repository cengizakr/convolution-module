from PIL import Image

def convert_to_8bit(input_image_path, output_image_path):
    # Open the 24-bit grayscale image
    image = Image.open(input_image_path)

    # Convert to 8-bit mode
    image = image.convert('L')

    # Save the 8-bit image
    image.save(output_image_path)

def jpg_to_hex(input_image_path, output_hex_path):
    # Open the 8-bit image
    image = Image.open(input_image_path)

    # Open the output hex file for writing
    with open(output_hex_path, 'w') as hex_file:
        # Iterate over each pixel value (byte) in the image
        for pixel_value in image.getdata():
            # Write each pixel value in a new line in hexadecimal format
            hex_file.write(format(pixel_value, '02X') + '\n')

if __name__ == "__main__":
    # Specify the input and output paths
    input_image_path = 'image.jpg'
    output_image_path = 'output_image_8bit.jpg'
    output_hex_path = 'output_hex.hex'

    # Convert the image to 8-bit
    convert_to_8bit(input_image_path, output_image_path)

    # Convert the 8-bit image to a hex file
    jpg_to_hex(output_image_path, output_hex_path)
