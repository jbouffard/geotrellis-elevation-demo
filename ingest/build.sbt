name := "ingest"

val geotrellisVersion = "1.0.0-RC3"

libraryDependencies ++= Seq(
  "com.azavea.geotrellis" %% "geotrellis-spark-etl" % "1.0.0-SNAPSHOT",
  "org.locationtech.geotrellis" %% "geotrellis-spark-etl" % geotrellisVersion,
  "org.apache.spark"      %% "spark-core" % "2.0.1" % "provided"
)

fork in Test := false
parallelExecution in Test := false
