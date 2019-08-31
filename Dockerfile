FROM centos/ruby-25-centos7
MAINTAINER John Mitsch (jomitsch@redhat.com)

USER root
WORKDIR /root

# clone repos and set up
RUN git clone https://github.com/theforeman/foreman.git
RUN git clone https://github.com/Katello/katello.git
RUN echo "gemspec :path => '../katello', :development_group => 'katello_dev', :name => 'katello'" >> foreman/bundler.d/katello.rb
COPY ./database.yml foreman/config/database.yml

# install system dependencies and gems
RUN rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y libvirt-devel systemd-devel rubygem-qpid_messaging qpid-cpp-client-devel 

# Remove SCL nodejs
RUN yum remove -y rh-nodejs10*
RUN rm -rf /opt/rh/rh-nodejs10

# Install nodejs provided by centos, same as we use in katello development
RUN yum install -y nodejs

# Re-alias node and npm to the installed version
RUN alias node="/usr/bin/node"
RUN alias npm="/usr/bin/npm"

# Use correct $PATH
ENV PATH "/opt/rh/rh-ruby25/root/usr/local/bin:/opt/rh/rh-ruby25/root/usr/bin:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# install dependencies
RUN /bin/bash -l -c "cd /root/foreman && scl enable rh-ruby25 -- bundle install --jobs=5"
RUN cd /root/foreman && npm install

COPY ./entrypoint.rb /usr/local/bin/entrypoint

ENTRYPOINT ["scl", "enable", "rh-ruby25", "--", "entrypoint"]
