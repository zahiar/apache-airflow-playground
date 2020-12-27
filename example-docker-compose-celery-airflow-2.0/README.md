# Example: Run Airflow 2.0 with Celery via docker-compose

This example shows you how to run Airflow 2.0 (using official docker image) with its dependencies using docker-compose.

Please note that Airflow 2.0 will contain backwards incompatible changes,
for example, I found the following airflow CLI changes:

| Old Commands | New Commands  |
|--------------|---------------|
| initdb       | db init       |
| flower       | celery flower |
| worker       | celery worker |

## Instructions

On the very first run, you will need to initialise the database, which you can do by running this command. You only need
to run this once, or every time you delete the containers/volumes - data should persist between container stop/starts.
```
docker-compose run webserver db init
docker-compose run webserver users create -r Admin -u admin -e admin@example.com -f admin -l user -p admin
```

Then run this to start up Airflow:
```
docker-compose up
```

Once started, you'll be able to access the following:
1. Airflow Web UI (Credentials: `admin:admin`): http://localhost:8080
1. Flower UI: http://localhost:5555
