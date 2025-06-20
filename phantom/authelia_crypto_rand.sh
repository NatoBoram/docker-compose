#!/bin/sh

docker run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric
