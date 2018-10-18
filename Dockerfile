FROM python:3.6

WORKDIR /app
ENV PYTHONPATH "${PYTHONPATH}:/app/src/"


# install donkey with tensorflow (cpu only version)
COPY ./requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt


RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.password = ''">>/root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''">>/root/.jupyter/jupyter_notebook_config.py


#start the jupyter notebook
CMD jupyter notebook --no-browser --ip 0.0.0.0 --port 8888 --allow-root  --notebook-dir=/notebooks/


#for donkeycar
EXPOSE 8887

#for jupyter notebook
EXPOSE 8888