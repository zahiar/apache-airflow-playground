# Example: Run Airflow with Celery via docker-compose

This example shows you how to run Airflow (using official docker image) with its dependencies using docker-compose.

## Instructions

On the very first run, you will need to initialise the database, which you can do by running this command. You only need
to run this once, or every time you delete the containers/volumes - data should persist between container stop/starts.
```
docker-compose run webserver initdb
```

Then run this to start up Airflow:
```
docker-compose up
```

Once started, you'll be able to access the following:
1. Airflow Web UI: http://localhost:8080
1. Flower UI: http://localhost:5555
