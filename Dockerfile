# docker build -t train/dns-zone-manager .
# Debian 12 (bookworm) on purpose: its system Python is 3.11, so the python3-ldns package installed
# below is built for the same interpreter this image runs. The bare python:3.11 tag moved to Debian 13,
# whose python3-ldns targets Python 3.13 and cannot be imported here.
FROM python:3.11-bookworm

# Install dependencies for setup. NSD python bindings (not available in pip)
RUN apt update && apt install nsd python3-ldns cron systemd -y
RUN update-rc.d nsd defaults && service nsd start
WORKDIR /usr/lib/zonemgr

COPY . /usr/lib/zonemgr

# path for source code.
ENV ZM_PATH="/usr/lib/zonemgr/"
# path for variables including DB, zonefile and DNS config file
ENV VAR_PATH="/var/lib/zonemgr/"

# set permissions, add user and copy the ZM service to system folder
RUN chmod 777 -R "$ZM_PATH"
RUN adduser --system --home "$VAR_PATH" zonemgr

# Install `prod` ZM dependencies
RUN pip3 install -e "."

ENV PORT_ENV="${PORT_ENV:-16001}"

# for ldns needed
ENV PYTHONPATH="${PYTHONPATH}:/usr/lib/python3/dist-packages/"

EXPOSE "${PORT_ENV}"
EXPOSE 53 53/udp

CMD ./script.sh "${PORT_ENV}"
