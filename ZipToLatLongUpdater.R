##Creates limited data set to continue conversion of ZIP code to latitude and##
##longitude coordinates.##


##Reads in ZIP to TRACT data from the US HUD.##
##Data from https://www.huduser.gov/apps/public/uspscrosswalk/home.##
ZIPtoTRACT<-read_xlsx(file.path(getwd(),"SupportingDocs","ZipToLatLong","ZIP_TRACT_062023.xlsx"))
ZIPtoTRACTReduced<-dplyr::select(ZIPtoTRACT,c("ZIP","USPS_ZIP_PREF_CITY","USPS_ZIP_PREF_STATE"))
ZIPtoTRACTReduced$USPS_ZIP_PREF_CITY<-str_to_title(ZIPtoTRACTReduced$USPS_ZIP_PREF_CITY)

ZIPtoTRACTReduced <- ZIPtoTRACTReduced %>% 
  rename("name" = "USPS_ZIP_PREF_CITY",
         "admin1_code" = "USPS_ZIP_PREF_STATE")

##Data from https://download.geonames.org/export/dump/##.
##Some example code used from https://poldham.github.io/abs/geonames.html##.
##Downloads and unzips a mapping file from location name to lat/long.##
temp <- tempfile()
download.file("http://download.geonames.org/export/dump/US.zip", temp)
US <- unzip(temp, exdir=file.path(getwd(),"SupportingDocs","ZipToLatLong"))

NameToLatLong<-read_tsv(file=file.path(getwd(),"SupportingDocs","ZipToLatLong","US.txt"),
                           col_names = FALSE)
NameToLatLong <- dplyr::rename(NameToLatLong, "geonameid" = "X1", "name" = "X2", 
                               "asciiname" = "X3", "alternatenames" = "X4", "latitude" = "X5",
                               "longitude" = "X6", "feature_class" = "X7", 
                               "feature_code" = "X8","country_code" = "X9", "cc2" = "X10",
                               "admin1_code" = "X11", "admin2_code" = "X12",
                               "admin3_code" = "X13", "admin4_code" = "X14", 
                               "population" = "X15", 
                               "elevation" = "X16", "dem" = "X17", 
                               "timezone" = "X18", "modification_date" = "X19")
NameToLatLongReduced<-dplyr::select(NameToLatLong,c("name","latitude","longitude", "admin1_code"))


##Join the two reduced data sets.##
NameToLatLongReducedJOINED<-merge(ZIPtoTRACTReduced, NameToLatLongReduced, 
                                  by=c("name","admin1_code"), all.x=TRUE)