library(dplyr)


portFiles <- list.files()
compiledData <- data.frame()
for (i in portFiles) {
  tempPort <- read.table(i, header = T, sep = "\t")
  compiledData <- rbind(compiledData, tempPort)
}
tickList <- unique(sort(compiledData$Ticks))
tickFiles <- paste0(tickList, ".stk")
compiledData <- compiledData %>% 
  mutate(enter = NA, exit = NA) 

for (i in 1:length(tickList)) {
  stkData <- read.table(tickFiles[i], sep = "\t", header = F)
  tempData <- filter(compiledData, Tick == tickList[i])
  enterDates <- match(tempData$Metric_Date, stkData[,1]) + 1
  
  exitDates <- match(tempData$Exit_Date, stkData[,1])
  
  
}




  mutate((exit - enter)/enter * 100)
