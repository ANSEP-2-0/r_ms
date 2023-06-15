library(rjson)

args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
    stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
    # print(args[1])
    options <- fromJSON(args[1])
    print(options$uptake$active)
}