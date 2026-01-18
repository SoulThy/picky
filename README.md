# picky

A bash script for reviewing photos one at a time and deciding whether to keep or delete them.

## usage
```bash
./picky.sh "/path/to/photos"
```

The script will open each image and ask if you want to keep or delete it.

## requirements

- zenity
- an image viewer (eog, feh, gwenview, etc)

The script auto-detects which viewer you have installed.

MIT
