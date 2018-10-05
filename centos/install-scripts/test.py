from pyspark.sql import SparkSession
import random
from random import randint


testfn = 'test-' + str(random.randint(1,10**10))
spark = SparkSession.builder.appName("repartition").getOrCreate()
df0 = spark.createDataFrame([("john-" + str(randint(0, 99999)), randint(0, 99999)) for _ in range(10)], ('name', 'age'))
df0.write.parquet('s3a://id-platform/benchmark/v1/'+testfn)
df1 = spark.read.parquet("s3a://id-platform/benchmark/v1/"+testfn)
df2 = df1.repartition(1300)
df2.write.mode("overwrite").partitionBy("name").parquet("s3a://id-platform/benchmark/v2/"+testfn)
spark.stop()

