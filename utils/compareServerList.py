## run the code under data directory
import os
import sys
from datetime import datetime, timezone

if len(sys.argv) == 3:
    correct_directory = "../" + sys.argv[1] + "/ovpn_udp/"
    country = sys.argv[2].upper()
    data_directory = "./country/" + country

    if os.path.isdir(correct_directory):
        if os.path.isdir(data_directory):
            if not os.path.exists("error"):
                os.makedirs("error")
            with open("./error/" + country + ".txt", "a") as error_list:
                correct_list = []
                data_list = []
                for filename in sorted(os.listdir(correct_directory)):
                    ID = filename.split(".")[0]
                    if "-" in ID:
                        continue
                    else:
                        if "".join(filter(lambda c: not c.isdigit(), ID)).upper() == country:
                            correct_list.append(ID)

                for filename in sorted(os.listdir(data_directory)):
                    ID = filename.split(".")[0]
                    data_list.append(ID)

                for ID in correct_list:
                    if ID not in data_list:
                        error_list.write(ID + "\n")
        else:
            print("Error: " + data_directory + "directory not exists")
            sys.exit()
    else:
        print("Error: " + correct_directory + "directory not exists")
        sys.exit()
else:
    print("!!!Usage: python3 compareServerList.py DIR COUNTRY!!!")
    sys.exit()
