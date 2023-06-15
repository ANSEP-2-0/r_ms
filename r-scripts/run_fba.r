#!/usr/bin/env Rscript
source("r-scripts/utils.r")
args = commandArgs(trailingOnly=TRUE)

runFBA <- function(sbmlPath, options=NULL) {
  metabolic_model = readModel(sbmlPath, options)
  run_options = fromJSON(options)
  
  solutionAlgorithm = if(run_options$fbaSolutionAlgorithm$active[1]) run_options$fbaSolutionAlgorithm$name else "fba"
  optL = optimizeProb(metabolic_model, algorithm = solutionAlgorithm, retOptSol = FALSE)
  # print(optL)
  optL$output <- capture.output(optL)
  fluxesData = {}
  fluxesData$reaction_position = optL$fldind
  fluxesData$reaction_id = metabolic_model@react_id
  fluxesData$reaction_name = metabolic_model@react_name
  fluxesData$reaction_flux = optL$fluxes
  outPlotDataFile <- tempfile("fba-data-", fileext = ".csv")
  columnNames = c("position", "Reaction id", "Reaction name", "flux")
  write.table(fluxesData, file = outPlotDataFile, row.names = FALSE, col.names = columnNames, sep = ",")
  
  systemTmp = systemTmpdir()
  outPlotDataFile = gsub(systemTmp, "", outPlotDataFile, fixed = TRUE)
  outCsvFile = gsub("\\\\", "/", outPlotDataFile)
  optL$csvPath = outCsvFile
  optL$okMessage = getMeanReturn(optL$ok)
  optL$statusMessage = getMeanStatus(optL$stat)
  
  return(toJSON(optL))
}

library(sybil)
library(sybilSBML)
library(rjson)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)>=1) {
  # options = fromJSON(args[1]) # JSON String must stat and end with '
  result = runFBA(args[1], args[2])
  print(result)
  # print(options$computeResults)
}