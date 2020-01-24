FROM ubuntu:16.04

# Install python3.6, pip3, other prerequisites for deepspeech
RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties && \
    add-apt-repository -y ppa:jonathonf/python-3.6 && \
    apt-get update && \
    apt-get -y install python3.6 &&\
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && \
    apt-get -y install python3-pip
RUN apt-get -y install libpthread-stubs0-dev python3.6-dev python-setuptools python3.6-gdbm build-essential autoconf libtool pkg-config python-opengl python-imaging python-pyrex python-pyside.qtopengl idle-python2.7 qt4-dev-tools qt4-designer libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-qt4-gl libgle3 python-dev libssl-dev libpq-dev python-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev
RUN apt-get -y install ffmpeg sox curl wget
RUN easy_install greenlet gevent
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get -y install git-lfs && \
    git lfs install
RUN pip3 install deepspeech

# Install Training Prerequisite (need DeepSpeech repo)
RUN pip3 install virtualenv && \
    virtualenv venv && \
    source venv/bin/activate
RUN git lfs clone https://github.com/mozilla/DeepSpeech.git && \
    cd DeepSpeech/
RUN pip3 install -r requirements.txt
RUN pip3 install $(python3 util/taskcluster.py --decoder) xdg


WORKDIR /app
