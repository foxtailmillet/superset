# sudo docker build . -t superset
# sudo docker run -d --rm --name superset -p 8080:8080 -v "$(pwd)/work:/home" superset
From python:3.7.4-buster
ARG user_name="*****"
ARG user_id="****"
ARG user_password="****"
ENV DEBIAN_FRONTEND noninteractive
ENV SUPERSET_CONFIG_PATH /home/superset/superset_config.py

# add package
RUN apt-get  update
RUN apt-get  install -y apt-utils
RUN apt-get  install -y aptitude
#RUN aptitude install -y ssh
RUN apt-get  install -y vim
RUN update-alternatives --set editor /usr/bin/vim.basic
RUN apt-get  install -y sudo

RUN apt-get install -y build-essential \
                       libssl-dev \
                       libffi-dev \
                       python3-dev \
                       python-pip \
                       libsasl2-dev \
                       libldap2-dev

RUN apt-get  install -y sqlite3

# locale ja_JP.UTF-8
#RUN apt-get install -y locales
#RUN sed -i 's/# ja_JP.UTF-8 UTF-8/ ja_JP.UTF-8 UTF-8/' /etc/locale.gen
#RUN locale-gen

# update pip
RUN pip install --upgrade setuptools pip

# Install depended package
RUN cd /tmp \
    && wget https://raw.githubusercontent.com/apache/incubator-superset/master/requirements.txt \
    && pip install -r requirements.txt

# Install superset
RUN pip install superset

# pandas downgrade
RUN pip uninstall -y pandas \
    && pip install pandas==0.23.4

# sqlalchemy downgrade
RUN pip uninstall -y sqlalchemy \
    && pip install sqlalchemy==1.2.18

# add db connect module
RUN pip install psycopg2
RUN pip install mysqlclient

# version check
RUN pip freeze \
    && python -c "from __future__ import print_function; import sys; print(sys.version_info)"


# add user
RUN adduser ${user_name} -u ${user_id} --disabled-login --gecos ''

RUN echo "${user_name}:${user_password}" |chpasswd
RUN echo "${user_name} ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo >/dev/null

#USER ${user_name}

VOLUME ["/home"]
WORKDIR /home

ADD superset_start.sh /home/superset_start.sh
ADD superset_config.py /home/superset_config.py.org

#RUN sudo chown ${user_name}:${user_name} /home/superset_start.sh
#RUN sudo chown ${user_name}:${user_name} /root/.superset/superset_config.py

EXPOSE 8080

ENTRYPOINT [ "/bin/bash", "/home/superset_start.sh" ]