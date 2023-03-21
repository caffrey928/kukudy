import os
import sys
from datetime import datetime, timezone

if len(sys.argv) == 2:
    data_directory = "../" + sys.argv[1] + "/"

    countryData = {}
    total_rounds = 0

    if os.path.isdir(data_directory):
        result_dir = data_directory + "Result/"

        if not os.path.exists(result_dir):
            os.makedirs(result_dir)

        # Iterate thru each round
        for item in os.listdir(data_directory):
            per_round = data_directory + "/" + item + "/"

            if not os.path.isdir(per_round) or item == "Result":
                continue
            
            if not os.path.exists(per_round + "country" + "/"):
                continue

            total_rounds += 1

            # Iterate thru all countries in current round
            for country in os.listdir(per_round + "country" + "/"):
                if not (country in countryData):
                    countryData[country] = {}

                # Analyze certain country in current round
                for filename in os.listdir(per_round + "country" + "/" + country + "/"):
                    if filename == "result.txt":
                        continue

                    CONFIG_ID = filename[:-4]
                    f = per_round + "country" + "/" + country + "/" + filename

                    if not (CONFIG_ID in countryData[country]):
                        countryData[country][CONFIG_ID] = 0
                    
                    with open(f, "r") as file:
                        for line in reversed(file.readlines()):
                            if line[0].isdigit():
                                break

                            if line[2] != "\t" and line[3] != "\t":
                                continue
                            
                            TWITCH_COUNTRY = line.split("\t")[0]
                            if TWITCH_COUNTRY == country or (TWITCH_COUNTRY == "GB" and country == "UK"):
                                countryData[country][CONFIG_ID] = countryData[country][CONFIG_ID] + 1

                            break
        
        # write data into result files
        for key in countryData:
            result_file = result_dir + key + ".txt"
            temp_rounds = total_rounds
            temp_array = []

            with open(result_file, "w") as result:
                result.write(str(datetime.now(timezone.utc)) + "\n")
                result.write(str(temp_rounds) + " Rounds: \n")

                for key, value in sorted(countryData[key].items(), key=lambda item: item[1], reverse=True):
                    if value < temp_rounds:
                        for config_id in sorted(temp_array):
                            result.write("\t" + config_id + "\n")
                        temp_rounds -= 1
                        result.write(str(temp_rounds) + " Rounds: \n")
                        temp_array = []
                    
                    if value == temp_rounds:
                        temp_array.append(key)

                for config_id in sorted(temp_array):
                    result.write("\t" + config_id + "\n")

                for i in range(temp_rounds):
                    result.write(str(temp_rounds - i - 1) + " Rounds: \n")

    else:
        print("Error: directory not exists")
        sys.exit()
else:
    print("!!!Usage: sudo python3 handleCountryData_v2.py DIR!!!")
    sys.exit()
