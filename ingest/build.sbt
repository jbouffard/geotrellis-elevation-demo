name := "ingest"

libraryDependencies ++= Seq(
  "org.locationtech.geotrellis" %% "geotrellis-spark-etl" % "1.0.0-RC3",
  "org.apache.spark"      %% "spark-core" % "2.0.1" % "provided"
)

fork in Test := false
parallelExecution in Test := false
