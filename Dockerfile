#docker run -ti --rm
# FROM r-base
# COPY . /usr/local/src/myscripts
# WORKDIR /usr/local/src/myscripts
# RUN ["sudo", "apt-get", "install", "libcurl4-openssl-dev"]
# RUN ["Rscript", "install_base.r"]
# RUN ["Rscript", "install_sybil.r"]
FROM r-base:4.0.4
# install R and rpy2
#RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/'
COPY docker/data /docker-req
RUN apt update
#RUN apt-key add /docker-req/rbase1.key

RUN apt-get -y install r-base r-base-core r-recommended r-base-dev
RUN apt-get install -y libxml2-dev build-essential libffi-dev python3-dev libcurl4-openssl-dev libssl-dev lib32ncurses5-dev libreadline-dev libglpk-dev
RUN R --version

# Install libSBML
RUN tar -xxvf /docker-req/libSBML-5.17.0-core-plus-packages-src.* -C /docker-req \
	&& cd /docker-req/libSBML-5.17.0-Source \
	&& ./configure --prefix=/usr/local --enable-cpp-namespace --enable-fbc --enable-shared --with-gnu-ld --enable-layout --enable-comp --enable-qual --enable-groups --enable-compression --enable-shared-version \
	&& make \
	&& make install
RUN ldconfig
ENV DYLD_LIBRARY_PATH /usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/lib

# Install Sybil R pacakges
COPY docker/scripts/install_base.r /docker-scripts/
RUN Rscript /docker-scripts/install_base.r
RUN apt-get -y install r-cran-devtools libgit2-dev
COPY docker/scripts/install_sybil.r /docker-scripts
RUN Rscript /docker-scripts/install_sybil.r
COPY sbml /sbml
COPY r-scripts /r-scripts
