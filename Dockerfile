# Spizhenno s foruma by Sergey @hackfeed Kononenko, ICS7-53B, 2020

FROM postgres

RUN apt-get update
RUN apt-get install python3 postgresql-plpython3-13 -y
