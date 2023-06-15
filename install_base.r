#!/usr/bin/Rscript

## Default repo
local({r <- getOption("repos")
       r["CRAN"] <- "http://cran.r-project.org" 
       options(repos=r)
})
chooseCRANmirror(graphics=False, ind=1)

check_install <- function(package_name) {
	package_availbility=requireNamespace(package_name, quietly = TRUE)
	cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
	if (!package_availbility) {
		print('installing...')
		install.packages( package_name)
		library(package_name, character.only = TRUE)
	}
}

bioconductor_install <- function(package_name_exact) {
	package_name = paste("^", package_name_exact,"$", sep="")
	package_consult = BiocManager::available(package_name, include_installed = FALSE)
	package_installed = length(package_consult) == 0
	cat('Package ', package_name_exact, ' is installed? ', package_installed,'\n')
	if (!package_installed) {
		print('installing...')
		BiocManager::install(package_name_exact, ask = FALSE)
	}
}

check_install('BiocManager')
bioconductor_install('Biobase')
bioconductor_install('gage')

print('R base packages installed!')
