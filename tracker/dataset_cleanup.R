library(caret)
library(timeDate)
library(dplyr)
library(ggplot2)

# Load the original data
activity <- read.csv("data/Activity.csv")
sleep <- read.csv("data/Sleep.csv")
blood <- read.csv("data/Blood_pressure.csv")
weight <- read.csv("data/Weight.csv")

# Define the days off. They will be treated separately
daysoff <- as.factor(c(
        as.Date("2015-04-03"),
        as.Date("2015-04-06"),
        seq(as.Date("2015-04-25"),as.Date("2015-05-02"), by="day"),
        as.Date("2015-05-14"),
        as.Date("2015-05-25"),
        as.Date("2015-06-04"),
        seq(as.Date("2015-08-01"),as.Date("2015-08-09"), by="day")
))

# Create a timeline
days <- seq(as.Date("2015-04-01"), as.Date("2015-08-31"), by="day")
data <- data.frame(date = as.factor(days), Day.Type=factor(0, levels= c("WORKDAY","WEEKEND","HOLIDAY")))

# Clean the data
# There are days that have multiple information. Aggregate them
###############################
# ACTIVITY
###############################
activity <- subset(activity, select=c(-Elevation..m.))
activity <- rename(activity, 
                   date = Date, 
                   Distance.km=Distance..km.)
data <- merge(data, activity, by="date", all=TRUE)

###############################
# SLEEP
###############################
sleep$from.posix <- as.POSIXlt(sleep$from., format="%Y-%m-%d %H:%M")
sleep$from.date <- format(sleep$from.posix, "%Y-%m-%d")
sleep$from.time <- format(sleep$from.posix, "%H:%M")
sleep$to.posix <- as.POSIXlt(sleep$to., format="%Y-%m-%d %H:%M")
sleep$to.date <- format(sleep$to.posix, "%Y-%m-%d")
sleep$to.time <- format(sleep$to.posix, "%H:%M")

sleep <- transmute(sleep,
                   date = as.factor(to.date),
                   Deep.Sleep.hrs = deep..s./3600, 
                   Light.Sleep.hrs = light..s./3600, 
                   Total.Sleep.hrs = Deep.Sleep.hrs + Light.Sleep.hrs,
                   Awake.hrs = awake..s./3600,
                   Wake.Up.times = wake.up)

sleep <- aggregate(. ~ date, FUN=sum, data=sleep)
data <- merge(data, sleep, by="date", all=TRUE)

###############################
# BLOOD
###############################
blood$posix <- as.POSIXlt(blood$Date, format="%Y-%m-%d %I:%M %p")
blood$date <- format(blood$posix, "%Y-%m-%d")
blood$time <- format(blood$posix, "%H:%M")
blood <- subset(blood, select=c(-Date, -Comments, -posix, -time)) 

blood <- aggregate(. ~ date, FUN=mean, data=blood)
blood <- rename(blood, 
                Heart.Rate.bpm = Heart.rate..bpm.)
blood$date <- as.factor(blood$date)
data <- merge(data, blood, by="date", all=TRUE)

###############################
# WEIGHT
###############################
weight$posix <- as.POSIXlt(weight$Date, format="%Y-%m-%d %I:%M %p")
weight$date <- format(weight$posix, "%Y-%m-%d")
weight$time <- format(weight$posix, "%H:%M")
weight <- subset(weight, select= c(-Date, -Comments, -posix, -time, -Lean.mass....))

weight <- aggregate(. ~ date, FUN=mean, data=weight)
weight <- rename(weight, 
                 Weight.Kg = Weight..kg., 
                 Fat.Mass.percent = Fat.mass....) 
weight$date <- as.factor(weight$date)
data <- merge(data, weight, by="date", all=TRUE)

###############################
# HOLIDAYS
###############################
data[isWeekday(data$date), ]$Day.Type <- "WORKDAY"
data[isWeekend(data$date), ]$Day.Type <- "WEEKEND"
data[data$date %in% daysoff,]$Day.Type <- "HOLIDAY"

data$date <- as.Date(data$date)

# Store the data in a single file
saveRDS(data, file = "data/tracker_data.RDS")
