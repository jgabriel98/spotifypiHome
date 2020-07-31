# spotifypiHome
multiroom home audio/music center, with spotify and airplay support, using snapcast for the 'multiroom synchornization' part.

dependencies:
this project build shairport-sync from source, so to be able to install the server node, the following depencies requirements should be meet: <br/>
 `apt install autoconf automake libtool libdaemon-dev libpopt-dev libconfig-dev libssl-dev avahi-daemon libavahi-client-dev libsndfile1-dev`

there are no special dependencies needed to install the client nodes.

## Server Node installation

In your setup, you can have only one _Server node_, since it will be an interface beetween the user and the other nodes, showing as a **music player for the user** (spotify or airplay or bluetooth) 
and as an **syncrhonized audio stream source for the client nodes**.

To install and configure the server node, run the `setup.sh` script with sudo permissions from the device you wish to be the server.


## Client Node instalattion
**A Server Node can also be a Client Node**

In your setup you can have as many client nodes as you want (1,2,3,...maybe 10?). The client nodes you be the ones to receive and play the audio stream.

To install and configure a client node, run the `clientSetup.sh` script with sudo permissions from the device.



### Uninstalling

To uninstall, run the `uninstall.sh` script with sudo permissions.
It is a _uninstall client and server_ script.
