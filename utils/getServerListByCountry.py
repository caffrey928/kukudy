import os
import sys

if len(sys.argv) == 3:
    directory = "../" + sys.argv[1] + "/ovpn_udp/"
    country = sys.argv[2].upper()

    if os.path.isdir(directory):
        with open("../ServerList/" + country + ".txt", "w") as server_list:
            for filename in sorted(os.listdir(directory)):
                ID = filename.split(".")[0]
                if "-" in ID:
                    continue
                else:
                    if "".join(filter(lambda c: not c.isdigit(), ID)).upper() == country:
                        server_list.write(ID + "\n")
    else:
        print("Error: directory not exists")
        sys.exit()
else:
    print("!!!Usage: python3 getServerListByCountry.py DIR COUNTRY!!!")
    sys.exit()
