from PIL import Image

def create_image_from_file(input_file, output_file):
    # Read numbers from the text file
    with open(input_file, 'r') as file:
        numbers = [int(line.strip()) for line in file]

    # Determine the image dimensions
    width = 320
    height = 180

    # Create a new image with white background
    image = Image.new('L', (width, height), color=255)

    # Set pixel values based on the numbers from the file
    for y in range(height):
        for x in range(width):
            index = y * width + x
            if index < len(numbers):
                value = min(255, max(0, numbers[index]))  # Ensure the value is in the valid pixel intensity range
                image.putpixel((x, y), value)

    # Save the image to a file
    image.save(output_file)

if __name__ == "__main__":
    input_file = "input_giris.txt"  # Replace with the path to your input text file
    output_file = "output_cikis.jpg"  # Replace with the desired output image file path

    create_image_from_file(input_file, output_file)
    print(f"Image created and saved to {output_file}")
