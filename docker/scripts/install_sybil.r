#!/usr/bin/Rscript
#sudo apt-get install libcurl4-openssl-dev
#sudo apt-get install glpk-utils
#sudo apt-get install libglpk-dev

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

install_gage <- function(){
    if(!requireNamespace("BiocManager", quietly = TRUE))
        install.packages("BiocManager")
    BiocManager::install("gage")
}

install_glpkAPI <- function() {
    package_name="glpkAPI"
    package_availbility=requireNamespace(package_name, quietly = TRUE)
    cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
    if (!package_availbility) {
        print('installing...')
        devtools::install_url("https://cran.r-project.org/src/contrib/glpkAPI_1.3.4.tar.gz", upgrade = "always")
        library(package_name, character.only = TRUE)
    }
}

install_curl <- function() {
    package_name="curl"
    package_availbility=requireNamespace(package_name, quietly = TRUE)
    cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
    if (!package_availbility) {
        print('installing...')
        devtools::install_url("https://cran.r-project.org/src/contrib/curl_5.0.0.tar.gz", upgrade = "always")
        library(package_name, character.only = TRUE)
    }
}

install_exp2flux <- function() {
	package_name="exp2flux"
	package_availbility=requireNamespace(package_name, quietly = TRUE)
	cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
	if (!package_availbility) {
		print('installing...')
        devtools::install_url("https://cran.r-project.org/src/contrib/Archive/exp2flux/exp2flux_0.1.tar.gz", upgrade = "always")
		library(package_name, character.only = TRUE)
	}
}
# https://github.com/sbmlteam/libsbml/releases/download/v5.20.0/libSBML_5.20.0.tar.gz
install_libSBML <- function (){
    package_name="libSBML"
    	package_availbility=requireNamespace(package_name, quietly = TRUE)
    	cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
    	if (!package_availbility) {
    		print('installing...')
            devtools::install_url("https://github.com/sbmlteam/libsbml/releases/download/v5.20.0/libSBML_5.20.0.tar.gz", upgrade = "always")
    		library(package_name, character.only = TRUE)
    	}
}


install_sybilSBML <- function() {
	package_name="sybilSBML"
	package_availbility=requireNamespace(package_name, quietly = TRUE)
	cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
	if (!package_availbility) {
		print('installing...')
		devtools::install_url("https://cran.r-project.org/src/contrib/Archive/sybilSBML/sybilSBML_3.0.1.tar.gz", upgrade = "always")
		library(package_name, character.only = TRUE)
	}
}

install_sybil <- function() {
	package_name="sybil"
	package_availbility=requireNamespace(package_name, quietly = TRUE)
	cat('Package ', package_name, ' is installed? ', package_availbility,'\n')
	if (!package_availbility) {
		print('installing...')
		devtools::install_url("https://cran.r-project.org/src/contrib/Archive/sybil/sybil_2.2.0.tar.gz", upgrade = "always")
		library(package_name, character.only = TRUE)
	}
}

#check_install('glpkAPI')
check_install('rjson')
#check_install('curl')
check_install('httr')
check_install('devtools')
install_curl()
install_gage()
install_glpkAPI()
install_sybil()
install_exp2flux()
install_libSBML()
install_sybilSBML()

print('Sybil packages installed!')
