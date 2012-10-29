#!/bin/sh
cat gfwdomains | sed -n 's#^server=\/\(.*\.[a-z A-Z]*\)\/.*#\1#pg' > domains
