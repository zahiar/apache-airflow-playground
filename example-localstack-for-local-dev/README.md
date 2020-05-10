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

You will also need to add a new connection in order for the S3 DAG to run, so in the UI navigate to:
_Admin > Connections > Create_

And fill in with the following fields, all other fields should be left as-is:
```
Conn Id:   aws_localstack
Conn Type: Amazon Web Services
Login:     someAccessKeyId
Password:  someAccessKeySecret
Extra:     {"host":"http://localstack:4572"}
```

Note: it's the JSON in the `Extra` section that tells Airflow to use localstack, or whatever host value we provide.