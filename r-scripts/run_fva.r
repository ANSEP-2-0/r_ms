source("r-scripts/utils.r")
args = commandArgs(trailingOnly=TRUE)

runFVA <- function(sbmlPath, options=NULL) {
  metabolic_model = readModel(sbmlPath, options)
  
  outPlotFile <- tempfile("fva-plot-", fileext = ".png")
  optFVA <- fluxVar(metabolic_model, percentage = 80, verboseMode = 0)
  png(filename = outPlotFile, width = 600, height = 400)
  plot(optFVA)
  dev.off ()
  # print(optFVA)
  # dev.copy(device = jpeg, filename = outPlotFile, width = 600, height = 400)
  # dev.off ()
  
  plotData = {}
  plotData$reaction_position = optFVA@react@react_pos
  plotData$reaction_id = optFVA@react@react_id
  plotData$reaction_name = metabolic_model@react_name
  plotData$lower_boundary = optFVA@lp_obj[1 : optFVA@lp_num_cols]
  plotData$upper_boundary = optFVA@lp_obj[(optFVA@lp_num_cols + 1) : (optFVA@lp_num_cols * 2)]
  outPlotDataFile <- tempfile("fva-data-", fileext = ".csv")
  columnNames = c("position", "Reaction id", "Reaction name", "lower boundary", "Upper boundary")
  write.table(plotData, file = outPlotDataFile, row.names = FALSE, col.names = columnNames, sep = ",")
  
  systemTmp = systemTmpdir()
  outPlotFile = gsub(systemTmp, "", outPlotFile, fixed = TRUE)
  outPlotFile = gsub("\\\\", "/", outPlotFile)
  outPlotDataFile = gsub(systemTmp, "", outPlotDataFile, fixed = TRUE)
  outCsvFile = gsub("\\\\", "/", outPlotDataFile)
  
  result <- {}
  result$plotPath = outPlotFile
  result$csvPath = outCsvFile
  result$output = capture.output(optFVA)
  
  return(toJSON(result))
}


library(sybil)
library(sybilSBML)
library(rjson)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)>=1) {
  # options = fromJSON(args[1]) # JSON String must stat and end with '
  result = runFVA(args[1], args[2])
  print(result)
  # print(options$computeResults)
}