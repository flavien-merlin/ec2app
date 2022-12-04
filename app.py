import os
import time
import boto3
import logging
from pythonjsonlogger import jsonlogger

logger = logging.getLogger()

logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)

interval = os.environ.get('INTERVAL')
ec2 = boto3.resource('ec2')


def find_running_ec2():
    count = 0
    response = ec2.instances.all()
    for instances in response:
        for tag in instances.tags:
            if instances.state['Code'] == 16:
                if tag['Key'] == 'Name' and tag['Value'] == 'devops':
                    print("Cluster Name: {0}".format(tag['Value']))
                elif tag['Key'] == 'k8s.io/role/master' and tag['Value'] == '1':
                    print("Cluster IP: {0}".format(instances.public_ip_address))
    count = count + 1
    print("Running Cluster: " + str(count))


if interval == None:
    find_running_ec2()
else:
    while True:
        find_running_ec2()
        print("Sleep for {0} seconds".format(interval))
        time.sleep(int(interval))
