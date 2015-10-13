#!/bin/sh
cd dottle
(./dottle install install.conf.yml)
cd ..
rm -rf dottle
