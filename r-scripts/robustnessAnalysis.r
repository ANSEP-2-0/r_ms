source("r-scripts/utils.r")
args = commandArgs(trailingOnly=TRUE)

robustnessAnalysis <- function(sbmlPath, options=NULL) {
  metabolic_model = readModel(sbmlPath, options)
  run_options = fromJSON(options)
  
  points = 20
  outPlotFile <- tempfile("rob-analysis-plot-", fileext = ".png")
  optRobAna <- robAna(metabolic_model, ctrlreact = run_options$robustnessReaction, numP = points, verboseMode = 0)
  png(filename = outPlotFile, width = 600, height = 400)
  plot(optRobAna)
  dev.off ()
  # plot(optRobAna)
  # dev.copy(device = jpeg, filename = outPlotFile, width = 600, height = 400)
  # dev.off ()
  # print(optRobAna)
  
  plotData = {}
  plotData$point = seq(1, points)
  plotData$flux = optRobAna@ctrlfl
  plotData$objectives = optRobAna@lp_obj
  outPlotDataFile <- tempfile("rob-analysis-data-", fileext = ".csv")
  columnNames = c("point", "Flux", "Optimal objective")
  write.table(plotData, file = outPlotDataFile, row.names = FALSE, col.names = columnNames, sep = ",")
  
  systemTmp = systemTmpdir()
  outPlotFile = gsub(systemTmp, "", outPlotFile, fixed = TRUE)
  outPlotFile = gsub("\\\\", "/", outPlotFile)
  outPlotDataFile = gsub(systemTmp, "", outPlotDataFile, fixed = TRUE)
  outCsvFile = gsub("\\\\", "/", outPlotDataFile)
  
  result <- {}
  result$plotPath = outPlotFile
  result$csvPath = outCsvFile
  result$output = capture.output(optRobAna)
  
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
  result = robustnessAnalysis(args[1], args[2])
  print(result)
  # print(options$computeResults)
}