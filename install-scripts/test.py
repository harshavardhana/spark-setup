from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("repartition").getOrCreate()
df = spark.createDataFrame([('john', 33)], ('name', 'age'))
df.write.json('s3a://id-platform/test_1')
