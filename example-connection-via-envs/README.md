# Example: Setting Connections via Environment Variables (ENVs)

This example is the same as the LocalStack one except here, we set the connection using an Environment Variable (ENV),
instead of an explicit connection set in the UI - which makes it much easier to manage multiple connections across many 
environments - no need for any manual setup, just set the ENVs and go :)

The connection ENV for an AWS connection in this case, looks like:
`AIRFLOW_CONN_AWS_LOCALSTACK: aws://someAccessKeyId:someAccessKeySecret@/?host=http://localstack:4572`

`AIRFLOW_CONN_` is the prefix that tells Airflow to treat this as a Connection. Anything that follows, is the name of 
the Connection.

The Connection string itself is a URI and is broken down like so:
`PROTOCOL://USERNAME:PASSWORD@HOST:PORT/SCHEMA?KEY1=VALUE1&KEY2=VALUE2`

And here's what each part means:
```
PROTOCOL  = connection type, e.g. aws, s3, mysql, http, https
USERNAME  = username for authentication or the AWS Access Key ID for Amazon Resources
PASSWORD  = password for authentication or the AWS Access Secret Key for Amazon Resources
HOST      = host to connect to or for some connection types like AWS can be left blank
PORT      = port to connect to
SCHEMA    = schema to use for database type connections
KEY/VALUE = these values will be added into the Extra field as a JSON representation
            E.G. {"KEY1": "VALUE1", "KEY2": "VALUE2", ...}
```

You may not need all of these, so fill in the ones you think you'll need and give it a go.

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
