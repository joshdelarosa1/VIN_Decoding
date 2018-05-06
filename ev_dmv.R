library("readr")
library("downloader")

# run the file from the web or local drive.

## down load the file from the web
web <-'url("https://data.ny.gov/api/views/w4pv-hbkt/rows.csv?accessType=DOWNLOAD")'

## run the file from a local dir
local <- '/Users/josuedelarosa/dev/EVs/Vehicle__Snowmobile__and_Boat_Registrations.csv'


# read in the file
Vehicle_Snowmobile_and_Boat_Registrations <- read_csv(local, 
                                                      col_types = cols(`Body Type` = col_character(), 
                                                                       City = col_character(), Color = col_character(), 
                                                                       County = col_character(), `Fuel Type` = col_character(), 
                                                                       Make = col_character(), `Maximum Gross Weight` = col_number(), 
                                                                       `Model Year` = col_date(format = "%Y"), 
                                                                       Passengers = col_character(), `Record Type` = col_character(), 
                                                                       `Reg Expiration Date` = col_date(format = "%m/%d/%Y"), 
                                                                       `Reg Valid Date` = col_date(format = "%m/%d/%Y"), 
                                                                       `Registration Class` = col_character(), 
                                                                       `Revocation Indicator` = col_character(), 
                                                                       `Scofflaw Indicator` = col_character(), 
                                                                       State = col_character(), `Suspension Indicator` = col_character(), 
                                                                       `Unladen Weight` = col_number(), 
                                                                       VIN = col_character(), Zip = col_character()))
# review the file
summary(Vehicle_Snowmobile_and_Boat_Registrations)

# clean up the file names
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Record Type"] <- "record_type"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Registration Class"] <- "registration_class"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Model Year"] <- "model_year"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Body Type"] <- "body_type"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Fuel Type"] <- "fuel_type"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Unladen Weight"] <- "unladen_weight"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Maximum Gross Weight"] <- "maximum_gross_weight"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Reg Valid Date"] <- "reg_valid_date"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Reg Expiration Date"] <- "reg_expiration_date"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Scofflaw Indicator"] <- "scofflaw_indicator"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Suspension Indicator"] <- "suspension_indicator"
colnames(Vehicle_Snowmobile_and_Boat_Registrations)[colnames(Vehicle_Snowmobile_and_Boat_Registrations)=="Revocation Indicator"] <- "revocation_indicator"

names(Vehicle_Snowmobile_and_Boat_Registrations)

# sub set the file to vehicles, passenger, electric fuel with a model year of 2015 or creater
attach(Vehicle_Snowmobile_and_Boat_Registrations)
Vehicle_Snowmobile_and_Boat_Registrations$myear4 <- substr(model_year,1,4)
detach(Vehicle_Snowmobile_and_Boat_Registrations)

attach(Vehicle_Snowmobile_and_Boat_Registrations)
Vehicle_Regi <- Vehicle_Snowmobile_and_Boat_Registrations[ which(record_type=='VEH' 
                                                                 & registration_class=='PAS' 
                                                                 & fuel_type=='ELECTRIC' 
                                                                 & myear4>2014),]
detach(Vehicle_Snowmobile_and_Boat_Registrations)

# create temp dir for VIN results
setwd("/Users/josuedelarosa/dev/EVs/API_Results")

# create a var with number of rows. this is needed for the loops
loop<-nrow(Vehicle_Regi)

# create a loop and dowload the vin data
attach(Vehicle_Regi)
for( i in 1:loop){ 
  download.file( paste0("https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/",
                        VIN[i],"?format=csv&modelyear=",myear4[i]), 
                 destfile=paste0("test_", i ,".csv"))}
detach(Vehicle_Regi)

# combine the vin files
files  <- list.files(pattern = '\\.csv')
tables <- lapply(files, read.csv, header = TRUE)
combined.df <- do.call(rbind , tables)

# dump the temp vin files
do.call(file.remove, list(list.files("/Users/josuedelarosa/dev/EVs/API_Results", full.names = TRUE)))

# combine the NYS file with the NHTS file

nys_vin <- merge (Vehicle_Regi2,combined.df, by.x="VIN", by.y="vin",all.x = TRUE)