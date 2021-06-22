FROM ubuntu:18.04

#https://github.com/AugurProject/ethereum-nodes/tree/master/geth-poa

RUN sudo add-apt-repository -y ppa:ethereum/ethereum

RUN sudo apt-get update && \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    ethereum \
    docker.io \
    docker-compose
#https://www.sitepoint.com/puppeth-introduction/
RUN mkdir app
WORKDIR app
RUN sudo usermod -a -G docker $USER
RUN mkdir node1 node2
RUN geth --datadir node1 --password 123456 account new && \
    geth --datadir node2 --password 123456 account new

