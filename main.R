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
library(xlsx)

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


# Run query
t_life_2017 <- dbGetQuery(jdbcConnection, "select * from t_life_2017")

# Close connection
dbDisconnect(jdbcConnection)





#########################################################################################
# Transform Data ########################################################################
#########################################################################################

# Clean dataset -------------------------------------------------------------------------
t_life_2017 <- t_life_2017[!is.na(t_life_2017$SZEGMENS), ]

# Add prod name
prod_names <- read.xlsx(here::here("Data", "t_life_prods.xlsx"), sheetIndex = 1, 
                        stringsAsFactors = FALSE, encoding = 'UTF-8'
  )

t_life_2017 <- t_life_2017 %>% left_join(prod_names, by = c("F_MODKOD"))


# Save res to local storage--------------------------------------------------------------
write.csv(t_life_2017, here::here("Data", "t_life_2017.csv"), row.names = F)



#########################################################################################
# Aggregate #############################################################################
#########################################################################################

segments <- t_life_2017 %>% group_by(SZEGMENS) %>% 
                            summarize(DARAB = n(),
                                      FTE = sum(IDO_PERC, na.rm = TRUE)/60/7/220,
                                      LETSZAM = sum(IDO_PERC, na.rm = TRUE)/60/7/220*1.3)

write.xlsx(segments, here::here("Data", "segs_to_excel.xlsx"))


lead_time <- t_life_2017 %>% group_by(SZEGMENS) %>% 
                          summarize(DARAB = n(),
                                    ERK_SZERZ = mean(ERK_SZERZ, na.rm = TRUE))

write.xlsx(lead_time, here::here("Data", "leadtime_to_excel.xlsx"))


# Plot -----------------------------------------------------------------------------------
prod_struct <- t_life_2017 %>%
  filter(RNEV != "Egyéb") %>%
  group_by(SZEGMENS, RNEV) %>%
  summarise(TOTAL = n()) %>%
  mutate(RATIO = TOTAL / sum(TOTAL))

ggplot(prod_struct, aes(factor(1), RATIO, fill = factor(RNEV), label = RNEV)) +
  geom_bar(stat = "identity") +
  geom_text(check_overlap = TRUE, size = 2, position = position_stack(vjust = 0.5)) +
  facet_grid(. ~ SZEGMENS) +
  facet_grid(. ~ SZEGMENS) +
  scale_y_continuous(label = percent) +
  scale_x_discrete(breaks = NULL) +
  theme(legend.position = "none") +
  labs(
    x = "SZEGMENS",
    y = "ARÁNY"
  )
ggsave(here::here("Reports", "prod_per_seg.png"),
  width = 10,
  dpi = 500
)