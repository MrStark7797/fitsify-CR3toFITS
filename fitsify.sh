#!/bin/bash

# Define source and destination directories
SOURCE_DIR="/home/user/Pictures/DslrDashboard/"
DEST_DIR="/home/user/SirilLive/"
ARCHIVE_DIR="/home/user/PhotoArchive/"

# Monitor for new files
while true; do
	echo "Waiting for new file"
	echo ""
	inotifywait --quiet -m -e close_write "$SOURCE_DIR" --format "%f" |
	for i in {1..10000000000}
	do
		tmp=0
	done
	#echo "1"
	for file in "$SOURCE_DIR"*; do
		# Only process .cr3 files
		#echo "2"
		if [[ "$file" == *.CR3 ]]; then

		    # Full path to the new file
		    FILEPATH="$file"
		    echo "New CR3 file detected: $FILEPATH \r"

		    # Convert CR3 to PPM using dcraw_emu 
#(updated version of dcraw that supports more file types)
		    TEMP_PPM="${FILEPATH}.ppm"
		    dcraw_emu -4 "$FILEPATH"  # Outputs a PPM with the same name

		    if [[ -f "$TEMP_PPM" ]]; then
		        # Convert PPM to FITS using cfitsio
		        tmp=$(echo $file | sed 's#.*/##')
		        FITS_PATH="$SOURCE_DIR${tmp%.CR3}.fits"
		        pnmtofits "$TEMP_PPM" > "$FITS_PATH"
		        # Check if FITS was created successfully
		        if [[ -f "$FITS_PATH" ]]; then
		            #echo "Converted $FILEPATH to $FITS_PATH"
		            # Move the original CR3 file to the destination directory
		            mv "$SOURCE_DIR${tmp%.CR3}.fits" "$DEST_DIR"
		            mv "$file" "$ARCHIVE_DIR"
		            rm "$TEMP_PPM"  # Clean up temporary PPM file
		            echo "Successfully converted and saved $tmp"
		        else
		            echo "Failed to create FITS file for $FILEPATH"
		        fi
		    else
		        echo "Failed to convert $FILEPATH to PPM"
		    fi
		fi
    done
done
echo "Done"
