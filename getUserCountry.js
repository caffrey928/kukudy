const { readdir, readFile } = require("node:fs/promises");

const KAPI = require("./utils/API");
const { getTS, writeData, sleep } = require("./utils/utils");

const reqUserCountry = (userLogin) =>
  KAPI.reqPlaybackAccessToken(userLogin)
    .then((res) => {
      // if (!res.data.data.streamPlaybackAccessToken) throw "Token not found";
      return res.data.data.streamPlaybackAccessToken;
    })
    .then((sPAToken) => KAPI.reqUsherM3U8(sPAToken, userLogin))
    .then((res) => {
      return res.data;
    })
    .catch((err) => err.message);

const loadUserLogins = async () => {
  const file = await readdir("./ulgs")
    .then((files) => files.at(-1))
    .catch(() => []);

  return readFile(`./ulgs/${file}`, "utf-8").then((content) =>
    content.slice(0, -1).split("\n").slice(0, 3)
  );
};

const getUserCountry = async (location = "local") => {
  const countryPath = `./country/${location
    .replace(/[0-9]/g, "")
    .toUpperCase()}/${location}.tsv`;
  await writeData(countryPath, `${getTS()}\n`);

  await loadUserLogins().then((userLogins) =>
    userLogins.forEach(async (userLogin, index) => {
      await sleep(index * 40); // 25 Hz

      const res = await reqUserCountry(userLogin);

      const country =
        res.substring(0, 14) !== "Request failed"
          ? res.substring(
              res.search("USER-COUNTRY") + 14,
              res.search("MANIFEST-CLUSTER") - 2
            )
          : "Country Request Failed";
      const IP =
        res.substring(0, 14) !== "Request failed"
          ? res.substring(
              res.search("USER-IP") + 9,
              res.search("SERVING-ID") - 2
            )
          : "IP Request Failed";

      writeData(countryPath, `${country}\t${IP}\n`);
    })
  );
};

// node getUserCountry.js [LOCATION]
if (require.main === module) {
  const pargv = process.argv;

  if (pargv.length === 2) {
    getUserCountry();
  } else if (pargv.length === 3) {
    getUserCountry(pargv[2]);
  }
}
