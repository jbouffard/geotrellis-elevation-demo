clean:
	docker-compose down

# Step 1 (fs and HDFS)
get-data:
	docker run -v ${PWD}/data/:/data python:3.5 \
		python3 /data/download-and-preprocess.py /data/lancaster-pa-1-meter.csv --download_dir /data/download_data -o /data/source

# Step 2 (fs and HDFS)
ingest-assembly:
	./sbt "project ingest" assembly

# Step 3 (fs and HDFS)
server-assembly:
	./sbt "project server" assembly

# Step 4 FS
ingest-fs: clean
	docker-compose run spark-master spark-submit \
	  --master local[*] \
          --class geotrellis.elevation.Ingest --driver-memory 10G \
	  /ingest/target/scala-2.11/ingest-assembly-0.1.0.jar \
          --input "file:///ingest/conf/input-file.json" \
          --output "file:///ingest/conf/output-file.json" \
          --backend-profiles "file:///ingest/conf/backend-profiles.json"

# Step 5 FS
serve-fs: clean
	docker-compose run -p 8777:8777 -e BACKEND='file' spark-master spark-submit \
	  --master local[*] \
	  --driver-memory 10G \
	  --class geotrellis.elevation.Server \
	  /server/target/scala-2.11/server-assembly-0.1.0.jar

all-fs: get-data ingest-assembly server-assembly ingest-fs serve-fs

# Step 4 HDFS
up-hdfs: clean
	docker-compose up -d

# Step 4 HDFS
# Imports preprocessed elevation data GeoTiffs into HDFS
import-hdfs:
	docker-compose run hdfs-name hdfs dfs -copyFromLocal /data/source/ /source

# Step 5 HDFS
# Runs the GeoTrellis ingest into HDFS
ingest-hdfs:
	docker-compose run spark-master spark-submit \
	  --master local[*] \
	  --class geotrellis.elevation.Ingest \
	  --driver-memory 10G \
	  /ingest/target/scala-2.11/ingest-assembly-0.1.0.jar \
          --input "file:///ingest/conf/input-hdfs.json" \
          --output "file:///ingest/conf/output-hdfs.json" \
          --backend-profiles "file:///ingest/conf/backend-profiles.json"

# Step 6 HDFS
serve-hdfs:
	docker-compose run spark-master spark-submit \
	  --master local[*] \
	  --class geotrellis.elevation.Server \
	  /server/target/scala-2.11/server-assembly-0.1.0.jar




#etl: get-data import ingest

.PHONY: get-data import ingest etl
