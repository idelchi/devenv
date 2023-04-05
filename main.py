# A script that reads a file

def main():
    # Open a file for reading
    infile = open('philosophers.txt', 'r')

    # Read the contents of the file
    file_contents = infile.read()

    # Close the file
    infile.close()

    # Print the data that was read into memory
    print(file_contents)


# Call the main function
main()
