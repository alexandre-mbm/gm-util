gm-util
=======

> Facilitates to develop Greasemonkey scripts in any directory outside browser

## Setup

To install:
```bash
$ sudo cp gm-util.sh /usr/local/bin/gm-util
```

To uninstall:
```bash
$ sudo rm /usr/local/bin/gm-util
```

## Use

At first time
1. Create userscript on browser
1. Discover files: `gm-util ls`
1. Look path to file: `gm-util look STRING`
1. Make sure you are in your working directory
1. Get it by first time: `gm-util init FILEPATH`

Cyclically at current work directory
1. Make edits
1. Check the sync with browser: `gm-util diff FILE`
    - If necessary, sync from browser: `gm-util get FILE`
    - If necessary, sync to browser: `gm-util set FILE`
1. Manage your Git repository
