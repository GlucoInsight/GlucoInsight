FROM python:3.10
WORKDIR /

ENV TZ=Asia/Shanghai
RUN apt-get update
# RUN apt-get install ffmpeg libsm6 libxext6  -y
RUN echo $APPID
RUN echo $APPSECRET
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .

CMD ["gunicorn", "app:app", "-c", "./gunicorn.conf.py"]
# CMD [ "python", "app.py" ]