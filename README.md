# Static homepage generator - No JS

## How to use

1. Populate `bookmarks.txt`, example provided in `bookmarks.txt.example` file
2. Run `startpage-gen.sh`
3. Add some nice background pictures inside `pix` folder
4. Paste the following lines inside your crontab (startpage only regenerates if `bookmarks.txt` has changed)

```
* * * * * /path/to/repo/changebg.sh
* * * * * /path/to/repo/startpage-gen.sh
```

5. Change the search engine within the `startpage-gen.sh` if you wish
6. ???
7. Set the startpage to open in new tab (on Brave it's brave://settings/?search=New+tab+page+shows -> homepage; brave://settings/?search=Show+home+button, enable, enter path to your generated .html file, disable)
8. Profit
