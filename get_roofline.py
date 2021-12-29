import os
import csv
op_per_byte = 1
repeated = 100
output_filename = "roofline_server.csv"
res = [['op_per_byte', 'op_per_second']]
for op_per_byte in list(range(1, 200)) + [300, 400, 500, 1000, 5000, 10000, 50000, 100000]:
# for op_per_byte in [1, 10, 100, 1000, 10000, 100000, 1000000]:
    total = 0
    for i in range(repeated):
        total += float(os.popen("./get_roofline "+str(op_per_byte)).read().split()[1].split(":")[1])
    print("op_per_byte:", op_per_byte)
    print("op_per_second:", total/repeated)
    res.append([op_per_byte, total/repeated])
with open(output_filename, "w") as csvfile:
    writer = csv.writer(csvfile)
    for data in res:
        writer.writerow(data)