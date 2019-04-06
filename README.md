# AWS configuration using Terraform

This simple terraform plan will.


* Create EC2 instance with nginx as reverse proxy 80 -> http://localhost:8080/cgi-bin/
* Create new AMI using the previous EC2 instance
* Setup autoscaling for custom AMI created before
* Download python application from an git repository
* Setup systemd service to run python application (http.server).
* Creaate EC2 instance with HAproxy (sticky sessions + stats activated).
* Add EC2 instances created by the autoscaling to the HAproxy configuration.


## EC2 configuration for autoscaling

### NGINX
```
DOCUMENT_ROOT / => /opt/test
PROXY_REVERSE /cgi-bin => http://127.0.0.1:8080
GZIP activated
```

* Add the required set up to cache the proxied requests for 1 minute.
* Add headers to responses for static content to be cached by browsers by 1 hour.
* *Add headers to responses for proxied content to be cached by browsers by 10 minutes.

### Python application

```
WorkingDirectory=/opt/test/
ExecStart=/usr/bin/python3 -m http.server --cgi 8080 &
```
