# Databricks notebook source
"""Wordcount a specified file"""
#pylint: disable=E0602
TEXT_FILE = sc.textFile("dbfs:/wordcount/document.txt")
COUNTS = TEXT_FILE.flatMap(lambda line: line.split(" ")) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)

# COMMAND ----------
"""Generate dataframe"""
dataframe = spark.createDataFrame(COUNTS)
display(dataframe)

# COMMAND ----------
"""Saving dataframe"""
dataframe.write.format('parquet').mode('overwrite').save("dbfs:/wordcount/document-count.parquet")
