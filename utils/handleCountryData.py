import os
import sys
from datetime import datetime, timezone

if len(sys.argv) == 3:
    directory = "../" + sys.argv[1] + "/country/" + sys.argv[2]

    if os.path.isdir(directory):
        with open(directory + "/result.txt", "w") as result:
            result.write(str(datetime.now(timezone.utc)) + "\n")
            country = {}
            countryCount = {}
            unique_subnet = {}

            for filename in sorted(os.listdir(directory)):
                if filename != "result.txt":
                    CONFIG_ID = filename[:-4]
                    f = os.path.join(directory, filename)
                    with open(f, "r") as file:
                        for line in reversed(file.readlines()):
                            T_COUNTRY = line[:2]
                            IP = line[3:-1]
                            SUBNET = ".".join(IP.split(".")[:3])
                            if line[0].isdigit():
                                break
                            if line[2] != "\t" and line[3] != "\t":
                                break
                            if T_COUNTRY in country:
                                if CONFIG_ID in country[T_COUNTRY]:
                                    continue
                                else:
                                    country[T_COUNTRY] = country[T_COUNTRY] + CONFIG_ID + "\t" + IP + "\n\t"
                                    countryCount[T_COUNTRY] = countryCount[T_COUNTRY] + 1

                                    if SUBNET not in unique_subnet[T_COUNTRY]:
                                        unique_subnet[T_COUNTRY].append(SUBNET)
                            else:
                                country[T_COUNTRY] = CONFIG_ID + "\t" + IP + "\n\t"
                                countryCount[T_COUNTRY] = 1
                                unique_subnet[T_COUNTRY] = [SUBNET]
                else:
                    continue
            for key in sorted(country):
                result.write(key + " : " + str(countryCount[key]) + "\n\t")
                result.write(country[key][:-1])
            print(unique_subnet)
    else:
        print("Error: directory not exists")
        sys.exit()
else:
    print("!!!Usage: sudo python3 handleCountryData.py DIR COUNTRY!!!")
    sys.exit()
