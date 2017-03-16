# Contribution guidelines

Please contribute with any corrections, improvements and other languages. It's also possible to add other concepts. PR's and issues are welcome.

#### How to edit concepts and languages - structure
There are two separate files
* available-languages.json
 * This file contains the available languages and their highlight code. Any language here will be available, but only the first 4 is viewed initially (user can select in headers)
* concepts.json
 * Contains the concepts, notes, links and language implementations with examples.
 * Adding a new language here will also require a new language in available-languages.json
 * New concept can be added.

#### Running on your local machine
##### With Elm installed
[Install Elm here](https://elm-lang.org)

```Clone repo and use npm start to run development. Use npm run build for production."```

##### Without Elm installed
```Clone repo and use a nodejs http server like http-server to run inside the "docs folder. Copy the .json files to root when finished."```
