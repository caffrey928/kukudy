## run the code under data directory
import os
import sys

if len(sys.argv) == 2:
    country = "".join(filter(lambda c: not c.isdigit(), sys.argv[1])).upper()
    ID = sys.argv[1]

    if not os.path.exists("error"):
        os.makedirs("error")

    with open("./error/" + country + ".txt", "a") as error_list:
        error_list.write(ID + "\n")
else:
    print("!!!Usage: python3 writeErrorCountry.py CONFIG_ID!!!")
    sys.exit()