import csv
import os
import sys

delimiter = os.environ.get("TINKERBOX_CSV_DELIMITER", ",")
reader = csv.reader(sys.stdin, delimiter=delimiter)
writer = csv.writer(sys.stdout)
for row in reader:
    writer.writerow([cell.strip() for cell in row])
