#!/bin/sh

# Depends on gem install s3_uploader
s3uploader -p true -k $AWS_ACCESS_KEY -s $AWS_SECRET_KEY ~/code/kaleodocs documentation.kaleosoftware.com


