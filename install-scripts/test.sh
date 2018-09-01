#!/bin/bash

spark-submit \
		--conf spark.hadoop.fs.s3a.server-side-encryption-algorithm=SSE-C \
		--conf spark.hadoop.fs.s3a.server-side-encryption-key='MzJieXRlc2xvbmdzZWNyZXRrZXltdXN0cHJvdmlkZWQ=' \
		--conf fs.s3a.path.style.access=true \
		--conf fs.s3a.path.style.access=true \
		--conf fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
		test.py
