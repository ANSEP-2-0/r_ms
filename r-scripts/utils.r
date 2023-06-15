readModel <- function(sbmlPath, options) {
  mp <- system.file(package = "sybil", "extdata")
  if (hasArg(sbmlPath))
    metabolic_model = readSBMLmod(sbmlPath)
  else
    metabolic_model = readTSVmod(prefix = "Ec_core", fpath = mp, quoteChar = '"')
  
  if (is.null(options))
    return(metabolic_model)
  
  run_options = fromJSON(options)
  cat("sbmlPath size: ", nchar(run_options$sbmlPath[1]), "\n")
  print("run_options")
  print(run_options)
  if (run_options$reactionBoundaries$active[1]) {
    print("using custom reaction bounds")
    metabolic_model <- changeBounds(metabolic_model, run_options$reactionBoundaries$reactions, lb = run_options$reactionBoundaries$lowerBounds, ub = run_options$reactionBoundaries$upperBounds)
  } else if (run_options$expressionAnalysis$active[1]) {
    print("using Expression analysis file")
    expressionFilePath <- paste(run_options$appPath, "/spaces/", run_options$expressionAnalysis$path[1], sep = "")
    cat("File path: ", expressionFilePath, "\n")
    expressionData = as.matrix(read.csv(expressionFilePath, header = FALSE, row.names = 1))
    expressionData <- ExpressionSet(assayData = expressionData)
    # Applying exp2flux
    metabolic_model <- exp2flux(model = metabolic_model, expression = expressionData, missing = "mean")
  }
  
  if (run_options$objectiveReactions$active[1]){
    print("using custom objective reactions")
    metabolic_model = changeObjFunc(metabolic_model, run_options$objectiveReactions$reactions)
  }

  if (run_options$uptake$active[1]) {
    print("using custom uptake")
    # Uptake must be sorted according to the exchange reaction id
    metabolic_model <- changeUptake(metabolic_model, on = run_options$uptake$metabolites, rate = c(run_options$uptake$lowerBounds, run_options$uptake$upperBounds))
  } 
  
  return(metabolic_model)
}

readReactions <- function(metabolic_model) {
  reactions = {}
  reactions$names = metabolic_model@react_name
  reactions$ids = metabolic_model@react_id
  reactions$lowerBoundaries = metabolic_model@lowbnd
  reactions$upperBoundaries = metabolic_model@uppbnd
  return(reactions)
}

readExchangeReactions <- function(metabolic_model) {
  reactions <- tryCatch(
    {
       exchange_reactions = findExchReact(metabolic_model)
      reactions = {}
      reactions$reactions = exchange_reactions@react_pos
      reactions$reactionIds = exchange_reactions@react_id
      reactions$metabolites = exchange_reactions@met_pos
      reactions$metaboliteIds = exchange_reactions@met_id
      reactions$lowerBoundaries = exchange_reactions@lowbnd
      reactions$upperBoundaries = exchange_reactions@uppbnd

      uptake_reactions = uptReact(exchange_reactions)
      uptake_table = exchange_reactions[uptake_reactions]
      reactions$uptake = uptake_table@react_pos
      return(reactions)
    },
    error = function(e){
        reactions = {}
        reactions$reactions = list()
        reactions$reactionIds = list()
        reactions$metabolites = list()
        reactions$metaboliteIds = list()
        reactions$lowerBoundaries = list()
        reactions$upperBoundaries = list()
        reactions$uptake = list()
        return(reactions)
    }
    )
  return(reactions)
}

readMetabolites <- function(metabolic_model) {
  metabolites = {}
  metabolites$names = metabolic_model@met_name
  metabolites$ids = metabolic_model@met_id
  return(metabolites)
}

systemTmpdir <- function() {
  tm <- Sys.getenv(c('TMPDIR', 'TMP', 'TEMP'))
  d <- which(file.info(tm)$isdir & file.access(tm, 2) == 0)
  if (length(d) > 0)
    tm[[d[1]]]
  else if (.Platform$OS.type == 'windows')
    Sys.getenv('R_USER')
  else
    '/tmp'
}

description <- function(sbmlPath) {
  mp = system.file(package = "sybil", "extdata")
  if (hasArg(sbmlPath))
    metabolic_model = readSBMLmod(sbmlPath)
  else
    metabolic_model = readTSVmod(prefix = "Ec_core", fpath = mp, quoteChar = '"')

  # print(modelData)
  modelDescription = {}
  modelDescription$output = capture.output(metabolic_model)
  modelDescription$genes = metabolic_model@allGenes
  modelDescription$reactions = readReactions(metabolic_model)
  modelDescription$metabolites = readMetabolites(metabolic_model)
  modelDescription$exchangeReactions = readExchangeReactions(metabolic_model)
  modelDescription$objectiveReactions = as.list(which(metabolic_model@obj_coef %in% c(1)))
  
  return(toJSON(modelDescription))
}