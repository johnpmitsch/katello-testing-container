FROM centos/ruby-25-centos7
MAINTAINER John Mitsch (jomitsch@redhat.com)

USER root

# clone repos
RUN cd ~ && git clone https://github.com/theforeman/foreman.git
RUN cd ~ && git clone https://github.com/Katello/katello.git
RUN echo "gemspec :path => '../katello', :development_group => 'katello_dev', :name => 'katello'" >> ~/foreman/bundler.d/katello.rb

# install system dependencies and gems
RUN rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y libvirt-devel systemd-devel rubygem-qpid_messaging qpid-cpp-client-devel 
RUN /bin/bash -l -c "cd ~/foreman && bundle install"

# Remove SCL nodejs
RUN yum remove -y rh-nodejs10*
RUN rm -rf /opt/rh/rh-nodejs10

# Install nodejs provided by centos, same as we use in katello development
RUN yum install -y nodejs

# Re-alias node and npm to the installed version
RUN alias node="/usr/bin/node"
RUN alias npm="/usr/bin/npm"

# install node packages
RUN cd ~/foreman/ && npm i

