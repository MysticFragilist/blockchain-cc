# 3C
3C or Computer Craft Coin is a computercraft crypto currency based on blockchain for academic purpose and just for fun. Mining are all done by a computer inside a minecraft server. 

### Introduction
This is an old project that we talked among friends. We wanted to do it for such a long time for our server but never did fault of having no knowledge whatsoever in blockchain. As more and more tutorials are published with crypto being more mainstream, we decided to make a crypto currency just for fun in LUA targeted for computer craft (tweaked version).

So here is our first version of 3C, and hope it will be useful for you!

## Usage

## Installation
Create 3 folders inside the computercraft you wish to install 3C node into:
- `<path>/3c/`
- `<path>/3c/lib/`
- `<path>/3c/lib/externals/`

To install this repo unto a computercraft PC, you first need to put the file on a dedicated pastebin.
Here are my pastebin links:
| File | Link | Description |
| ---- | ---- | ----------- |
| `<path>/3c/3C.lua` | [https://pastebin.com/raw/3C](https://pastebin.com/raw/jwXZjYjq) | The main entry point of the program |
| `<path>/3c/lib/externals/md5.lua` | [https://pastebin.com/raw/jwXZjYjq](https://pastebin.com/raw/jwXZjYjq) | A simple md5 implementation |
| `<path>/3c/lib/externals/rsa-crypt.lua` | [https://pastebin.com/raw/jwXZjYjq](https://pastebin.com/raw/jwXZjYjq) | A simple RSA implementation |
| `<path>/3c/lib/mining.lua` | [https://pastebin.com/raw/jwXZjYjq](https://pastebin.com/raw/jwXZjYjq) | The mining module for 3C |
| `<path>/3c/lib/networking.lua` | [https://pastebin.com/raw/jwXZjYjq](https://pastebin.com/raw/jwXZjYjq) | The networking module for 3C |
| `<path>/3c/lib/blockchain.lua` | [https://pastebin.com/raw/jwXZjYjq](https://pastebin.com/raw/jwXZjYjq) | The blockchain module for 3C |

### Usage
Usage: 3c \<param\>
  Possible parameter to use:
  
    -i, --init: initialize the blockchain
    -f, --fetch \[host\]: connect to the network by passing through the known host, if none fetch
    -h, --help: show this help

### Credits
A huge thanks to @lhartikk for the nice tutorial on how to build a simple cryptocurrency. If you are interested in how to build a blockchain, check out [his](https://lhartikk.github.io/) series of articles.

### License
Disclaimer: This is an academic project. This project SHOULD NOT be used for commercial purposes. or for any trading or investment purposes. This was made using insecure implementation found lying on internet. Use at your own risk.

This project is licensed under the MIT license.
## Contributing
Want to contribute or found a bug? report it throught the issue channel or simply open up a PR, I'll be happy to help.
