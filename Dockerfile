FROM ubuntu:trusty-20150612

# Don't install recommended or suggested packages during apt-get installs
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf;
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf;

# install Haskell, LaTeX, and Node
RUN apt-get update && apt-get install -y \
    haskell-platform \
    libghc-pandoc-dev \
    lmodern \
    nodejs \
    qpdf \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-luatex \
    texlive-xetex \
    wget

# install pandoc
RUN cabal update && cabal install --global pandoc-1.15.0.4

# example command: docker run danielak/pandoc --version
WORKDIR /src
COPY . /src
CMD [ \
    "pandoc", \
    "test.md", \
    "--from=markdown", \
    "--to=latex", \
    "--output=test.pdf", \
    "--standalone" \
]
