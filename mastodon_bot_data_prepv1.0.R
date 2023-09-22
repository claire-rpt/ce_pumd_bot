library(tidyverse)
library(haven)
library(stats)
library(reldist)


#load data for 4 quarters of 2019 FMLI interview files

q1 <- read_sas("fmli191x.sas7bdat")
q2 <- read_sas("fmli192.sas7bdat")
q3 <- read_sas("fmli193.sas7bdat")
q4 <- read_sas("fmli194.sas7bdat")
q5 <- read_sas("fmli201.sas7bdat")

#change all column names to uppercase
names(q1) <- toupper(names(q1))
names(q2) <- toupper(names(q2))
names(q3) <- toupper(names(q3))
names(q4) <- toupper(names(q4))
names(q5) <- toupper(names(q5))

#combine quarterly data
df <- rbind(q1,q2,q3,q4,q5)

#cleaning the data
df <- df %>% filter(TOTEXPCQ>0)

year = 2019

df <- df %>% mutate(
  QINTRVMO = as.integer(QINTRVMO),
  QINTRVYR = as.integer(QINTRVYR),
  MO_SCOPE = ifelse(QINTRVYR %in% (year+1),4-QINTRVMO,ifelse(
    QINTRVMO %in% 1:3,QINTRVMO-1,3
  )),
  POPWT = (FINLWT21/4)*(MO_SCOPE/3)
)

df$QINTRVMO = as.integer(df$QINTRVMO)
df$QINTRVYR = as.integer(df$QINTRVYR)
df$STATE = as.integer(df$STATE)
df$MO_SCOPE = ifelse(df$QINTRVYR %in% (year+1),4-df$QINTRVMO,ifelse(df$QINTRVMO %in% 1:3, df$QINTRVMO-1,3))
df$POPWT = (df$FINLWT21/4)*(df$MO_SCOPE/3)

data <- df %>% filter(POPWT>0)

bls_format <- data %>%
  select(c("NEWID","POPWT","TOTEXPCQ","FINCBTXM","FINATXEM","FOODCQ","FDHOMECQ","FDXMAPCQ",
           "ALCBEVCQ","EHOUSNGC","ESHELTRC","APPARCQ","ETRANPTC","HEALTHCQ","EENTRMTC","PERSCACQ","READCQ",
           "EDUCACQ","TOBACCCQ","CASHCOCQ","LIFINSCQ","PERINSCQ","RETPENCQ","HLTHINCQ","OWNVACC","FFTAXOWE","FSTAXOWE","MISCTAXX",
           "PROPTXCQ","TOTXEST","EMRTPNOC","MRTINTCQ","RENDWECQ","MRPINSCQ","STATE","FAM_SIZE",
           "EOTHLODC","FAM_TYPE","CHILDAGE","EARNCOMP","EDUC_REF","PERSLT18","PERSOT64","AGE_REF","AGE2",
           "BEDROOMQ","BATHRMQ")) %>%
  mutate(POVERTY_LVL = 12490+4420*(FAM_SIZE-1)) %>%
  mutate(PPL = FINCBTXM/POVERTY_LVL)

#column names and numbers for expenditures
column_numbers <- seq.int(6,34)
column_names <- c(
  "Food",
  "Food at home",
  "Food away from home",
  "Alcohol",
  "Housing",
  "Mortgage/rent",
  "Clothing",
  "Transportation",
  "Health care",
  "Entertainment",
  "Personal care",
  "Reading",
  "Education",
  "Tobacco",
  "Cash contributions",
  "Life insurance",
  "Pensions and personal insurance",
  "Retirement, pensions, and social security",
  "Health insurance",
  "Vacation homes",
  "Federal taxes",
  "State taxes",
  "Misc taxes",
  "Property taxes",
  "Total taxes",
  "Mortgage principle",
  "Mortgage interest",
  "Rent",
  "Maintenance, repairs, and insurance"
)

selections <- data.frame(column_numbers,column_names)

#state FIPS code
STATE <- seq.int(1,56)
STATE <- STATE[STATE !=3]
STATE <- STATE[STATE!=7]
STATE <- STATE[STATE!=43]
STATE <- STATE[STATE!=52]
STATE <- STATE[STATE!=14]
s_names <- c("Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware",
             "District of Columbia","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa",
             "Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota",
             "Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico",
             "New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
             "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington",
             "West Virginia","Wisconsin","Wyoming")

state_fips <- data.frame(STATE,s_names)

#export CSVs for python portion
write.csv(state_fips,"state_fips.csv")
write.csv(bls_format,"bls_format.csv")
write.csv(selections,"expenditure_names.csv")