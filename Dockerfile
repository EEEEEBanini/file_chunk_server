# Builds a docker image configured for the dev environment.

FROM phusion/passenger-ruby22

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

ADD . /home/app/file_chunk_server

RUN mkdir /home/tmp
RUN head -c 100M </dev/urandom >/home/tmp/tmp_file
RUN chmod a+rw /home/tmp/tmp_file

# get rid of the version information in the path
RUN cd /home/app/file_chunk_server && bundle update && bundle install
RUN cd /home/app/file_chunk_server && RAILS_ENV=development bundle exec rake
RUN chown -R app:app /home/app/file_chunk_server

ADD file_chunk_server.conf /etc/nginx/sites-enabled/file_chunk_server.conf

EXPOSE 8889

RUN rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
