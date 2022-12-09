# kukudy

## Installation

1. `$ git clone git@github.com:hy-chou/kukudy.git`
2. `$ cd kukudy/`
3. `$ npm install`
4. Create a `.env` file inside `kukudy/` with the following content:

```.env
CLIENT_ID="vje46w2kigic6v7q7fsf8qo38fyr95"
# CLIENT_SECRET="kf9vc5rnm89t71o20ax31t84wkanbz"
ACCESS_TOKEN="jmisglktaqh44h2eabposxqpwdycul" # 2022-09-11

CLIENT_ID_GQL="kimne78kx3ncx6brgo4mv6wki5h1ko"
```

## Quick start guide

This tutorial gives basic instructions for the first-time probers to get started with kukudy.

### 1. The first probe

After installing kukudy, create a new directory named `playground` inside the root directory of kukudy, and go inside it. Next, run the following command:

```shell!
$ node ../updateStreams.js 100
```

Congratulations! You have done your first probe!

Let's see the data you just collected.

```shell!
$ ls -F
strm/  ulgs/
```

It seems like there are two directories. Let's check out `ulgs/` first.

#### ULGS

There is a `.txt` file inside `ulgs/`. The filename is the UTC time of the probe. This file contains 100 user logins which belong to the top 100 live channels.

To see the file content, run `$ cat FILENAME`.

The user logins are listed in descending order of viewer count. That is, the first channel has the most viewer of all live channels.

Is there more information about these channels? Let's move on to `strm/`.

#### STRM

There is a `.json.txt` file inside `strm/`. The filename is also the UTC time of the probe. This file contains the raw response from [Twitch API](https://dev.twitch.tv/docs/api/reference#get-streams), including two sections, data and pagination. The extra information of the channels is in the data section.

To see the extra information about the first channel, run `$ cat FILENAME | jq .data[0]`. 

### 2. Video edges

After the first probe, you have what it takes to find out the video edges serving these channels. Go back to the `playground` directory and run the following command:

```shell!
$ node ../updateEdges.js
```

Let's see what's new in the `playground`.

```shell!
$ ls -F
edgs/  strm/  ulgs/
```

It seems like there is one more directory called `edgs`. Let's check it out.

#### EDGS

There is a `.tsv` file inside `edgs/`. The filename is also a UTC timestamp.

To see the file content, run `$ cat FILENAME`.

As you can see, there are three things in every line, a UTC timestamp, a hostname, and a user login.

To see only the hostnames, run `$ cat FILENAME | cut -f 2`. To count the hostnames, run `$ cat FILENAME | cut -f 2 | sort | uniq -c | sort -gr`.

As you can tell, there are channels sharing an edge.

### 3. Probe faster with a shell script

Typing the same commands is exhausting. Is there a way to probe using one command?

Yes.

Let's try to probe the top 200 channels for 3 times. Before the probe, make sure you know the absolute path to `kukudy/`. If not, run `$ echo $PWD` inside `kukudy/`.

Now, run the following command:

```shell!
$ bash scripts/book.sh /ABS/PATH/TO/kukudy /ABS/PATH/TO/kukudy/playground 200 3
```

You will find three new files in `ulgs/`, three new files in `strm/`, and three new files in `edgs/`.

### 4. Schedule a probe with cron

Staying up late is tiring. Is it possible to probe when you are sleeping?

Yes.

Let's try to schedule a 1000-channel, 3-round probe at midnight.

Before the probe, make sure you know the absolute path to `kukudy/` and the user name of the mbox you are using. If not, run `$ echo $PWD ` inside `kukudy/` and `$ echo $USER`.

Now, create a cron file by running `$ sudo vim /etc/cron.d/kukudy`, and write the following lines.

```cron!
DIR_K=/ABS/PATH/TO/KUKUDY

59 23 * * * USER bash ${DIR_K}/scripts/book.sh ${DIR_K} ${DIR_K}/playground 1000 3
```

By doing so, you schedule a 1000-channel 3-round probe every single night at 23:59 (local time).

### 5. Probe via VPN

> Coming soon...

## Errors

### Request failed with status code 401

* You get 401 when the access token expires.
* To get a new token, use the following command. You can find the `CLIENT_ID` and `CLIENT_SECRET` in the `.env` file.

```shell!
$ curl -X POST 'https://id.twitch.tv/oauth2/token' \
       -F 'grant_type=client_credentials' \
       -F 'client_id=<CLIENT_ID goes here>' \
       -F 'client_secret=<CLIENT_SECRET goes here>'
```

* The reply will be in the json format.

```json!
{
  "access_token": "ntulee10lvwd19u69rt4f4lo2gm8vg",
  "expires_in": 4764969,
  "token_type": "bearer"
}
```

* Replace the access token in the `.env` file with the new one.
* An access token lasts about two months.

