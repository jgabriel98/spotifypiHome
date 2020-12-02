# spotifypiHome
A multiroom audio/music playback, with **spotify connect**, **airplay** and **bluetooth** support, using snapcast for the 'multiroom synchornization' part.\
note: even if it is a multiroom solution, you can use it as unique room playback device, with no problems.

This project uses [raspotify](https://github.com/dtcooper/raspotify), [shairport-sync](https://github.com/mikebrady/shairport-sync), [BlueALSA](https://github.com/Arkq/bluez-alsa)  and [snapcast](https://github.com/badaix/snapcast). Without them this project wouldn't be possible.

## Dependencies:
 - **Airplay**: this project build shairport-sync from source, so the following depencies requirements should be met: <br/>
   `$ apt install autoconf automake libtool libdaemon-dev libpopt-dev libconfig-dev libssl-dev avahi-daemon libavahi-client-dev libsndfile1-dev`

 - **Bluetooth**: some _alsa_ and _bluez_ packages are required, you can obtain them with: <br/>
    `$ apt install -y --no-install-recommends alsa-base alsa-utils bluez-tools`

there are no dependencies needed for client nodes.


## Server Node installation (audio receiver)

In your setup, you can have only one _Server node_, since it will be an interface beetween the user and the other nodes, acting as a **music playback device for the user** (spotify, airplay or bluetooth) 
and as an **syncrhonized audio stream source for the client nodes**.

To install and configure the server node, run the `serverInstall.sh` script with sudo permissions from the device you wish to be the server.

#### Flags

| flag            | description              |
|-----------------|--------------------------|
| `--no-spotify`  | disable spotify support  |
| `--no-shairport`| disable airplay support  |
| `--no-bluetooth`| disable bluetooth support|



## Client Node instalattion (audio playing)
**A Server Node can also be a Client Node**

In your setup you can have as many client nodes as you want (1,2,3,...maybe 20?). The client nodes will be the ones to receive and play the audio stream.

To install and configure a client node, run the `clientInstall.sh` script with sudo permissions from the device.
You can force the client node to use the headphone 3.5mm jack output with `--force-headphones` optional flag, instead of using system default device.:

`$ sudo ./clientInstall.sh --force-headphones`

note: you should check if you have the 'Headphones' playback device listed in alsa devices (with `$ aplay -l`)

#### Flags

| flag                  | description              |
|-----------------------|--------------------------|
| `--force-headphones`  | set headphone as output device |



### Uninstalling

To uninstall, run the `uninstall.sh` script with sudo permissions.<br/>
Works for both _client_ and _server_.



## Experimental
The current features are experimental and still needs some fine tuning. But if it is here, is because i found it usable already.

 - **client's bluetooth**: you can also connect to a client's bluetooth (instead of beeing limited to only the servernode's bluetooth).<br/>
 To enable this feature, run `enable-client-bluetooth__experimental.sh` script at `scripts/` folder.
 

## Roadmap
check the [spotifypiHome Developing page](https://github.com/jgabriel98/spotifypiHome/projects/1)
