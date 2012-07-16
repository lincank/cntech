#!/bin/sh
rake generate 
git add .
git commit -m "site update"
git push heroku master
