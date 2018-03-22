# Procedure to semgent one year of life sales to indentify best tier for process
# automation

# Exract data ---------------------------------------------------------------------------
# Load required libs
library(config)
library(here)
library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)
library(scales)

#Connect to Oracle (Kont@kt:MMBDBIKON)
# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME = "C:\\Program Files\\Java\\jre1.8.0_60")
options(java.parameters = "-Xmx2g")
library(rJava)

# Output Java version
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)

# Create connection driver and open connection
jdbcDriver <-
  JDBC(driverClass = "oracle.jdbc.OracleDriver",
       classPath = "C:\\Users\\PoorJ\\Desktop\\ojdbc7.jar")

# Get Kontakt credentials
kontakt <-
  config::get("kontakt",
              file = "C:\\Users\\PoorJ\\Projects\\config.yml")

# Open connection
jdbcConnection <-
  dbConnect(
    jdbcDriver,
    url = kontakt$server,
    user = kontakt$uid,
    password = kontakt$pwd
  )

# Get SQL script
readQuery <-
  function(file)
    paste(readLines(file, warn = FALSE), collapse = "\n")
segement_data <-
  readQuery(here::here("SQL", "segmentation_life_autouw.sql"))

# Run query
t_life_2017 <- dbGetQuery(jdbcConnection, segement_data)

# Close connection
dbDisconnect(jdbcConnection)


# Save res to local storage--------------------------------------------------------------
write.csv(t_life_2017, here::here("Data", "t_life_2017.csv"), row.names = F)



