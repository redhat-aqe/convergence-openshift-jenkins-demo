# About

This repository contains example files for Jenkins & OpenShift integration

## Files

* pipeline.yaml - example of a Jenkins Pipeline using DSL, JMS trigger,
     OpenShift pod for execution and  concurrency with throttling
* Dockerfile - example Dockerfile for Jenkins use. It would make sense to create
     custom images for specific jobs with custom environment based on this base
     image. 
* prometheus.yaml - example Prometheus OpenShift deployment for simple Jenkins
     monitoring with alerts sent over email
* gitlab-runners.yaml - example Gitlab runner deployment within OpenShift environment
