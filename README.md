# OSR
Open source experimental leaderboard for speedruns written in D and vibe.d

## Discord
There's a [Discord](https://discord.gg/v4ybzbP) server

## How to compile
Install the D toolchain and your compiler of choice and run
```
dub
```
In the root of the directory, OSR should be compiled and run.
You'll need a mongodb instance running for OSR to work.

This is being developed and tested on Linux, your milage may vary on other platforms.


## Directory Structure
 * source/
   * backend/ Backend implementation
   * api/ API definition and implementation
   * frontend/ Frontend implementation