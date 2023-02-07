const KAPI = require('./utils/API');
const { writeData, getTS } = require('./utils/utils');

const getStreams = async (endPage = 1) => {
  const strmPath = `./dump/getStreams/${getTS().replaceAll(':', '.')}.tsv`;
  const cursor = [''];
  const userLogins = new Set();

  for (let p = 0; p < endPage; p += 1) {
    // eslint-disable-next-line no-await-in-loop
    await KAPI.reqStreams(cursor[0])
      .then(async (res) => {
        const ts = getTS();
        const strHeaders = JSON.stringify(res.headers);
        const strData = JSON.stringify(res.data);
        await writeData(
          strmPath,
          `${ts}\t${p}\treqStreams\t${strHeaders}\t${strData}\n`,
        );

        return res.data;
      })
      .then((data) => {
        data.data.forEach((stream) => userLogins.add(stream.user_login));
        cursor.pop();
        cursor.push(data.pagination.cursor);
      })
      .catch(async (err) => {
        await writeData(
          `./errs/${getTS().slice(0, 13)}.tsv`,
          `${getTS()}\t@getStreams p${p}\t${err.message}\n`,
        );
      });

    if (typeof cursor[0] === 'undefined') {
      break;
    }
  }

  return userLogins;
};

const updateStreams = async (endPage = 1) => {
  const ulgsPath = `./ulgs/${getTS().replaceAll(':', '.')}.txt`;
  const userLogins = Array.from(await getStreams(endPage));
  const content = `${userLogins.join('\n')}\n`;

  await writeData(ulgsPath, content);
};

if (require.main === module) {
  const pargv = process.argv;

  if (pargv.length === 2) {
    updateStreams(1);
  } else if (pargv.length === 3) {
    const endPage = Math.ceil(Number(pargv[2]) / 100);

    updateStreams(endPage);
  }
}
