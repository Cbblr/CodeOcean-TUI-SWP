#!/bin/bash
cd codeocean
sudo service postgresql start
screen -S rails -m -d bundle exec rails server
screen -S webpack-dev-server -m -d yarn run webpack-dev-server
