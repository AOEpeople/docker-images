# curl2prometheus

This is a simple bash script that reads a list of urls from the "URLS" environment variable, runs curls with all of them 
and pushing timing results to a prometheus pushgateway (defined in environmant variable "PUSH_DESTINATION")

Run this as a Kubernetes cronjob for a simple mechanism to cellect some health metrics for a list of given urls.

Required environment variables:

- URLS
- PUSH_DESTINATION

**Example command:**

```
docker run --rm -i \
  -e URLS="https://www.google.com https://www.facebook.com" \
  -e PUSH_DESTINATION="http://pushgateway.example.org:9091/metrics/job/curl" \
  aoepeople/curl2prometheus:latest
```
