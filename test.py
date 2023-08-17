import os
import json
import boto3
from botocore.exceptions import ClientError
import logging


 
required_keys = os.environ["required_keys"].split(",")
outbound_topic_arn = os.environ["outbound_topic_arn"]
 
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)
log.setLevel(logging.DEBUG)



 
def lambda_handler(event, context):
    pre_keys = []
    missing_keys = []
    log.info(json.dumps(event))
    
    if bool(event) == True and event['detail']['eventName'] == "RunInstances":
        client = boto3.client('ec2')
        try:
            tags_val = event['detail']['responseElements']['instancesSet']['items'][0]['tagSet']
            log.debug(tags_val)
            for tag in tags_val['items']:
                log.debug(tag['key'])
                if tag["key"] in required_keys:
                    pre_keys.append(tag["key"])
        except:
            #tags_null = event['detail']['responseElements']['instancesSet']['items'][0]['tagSet']
            tags_null = event['detail']['responseElements']['instancesSet']['items'][0]['networkInterfaceSet']['items'][0]['tagSet']
            log.debug(tags_null)
            if bool(tags_null) == False:
                return send_null_violation(event)

 
    #S3 notification
    if bool(event) == True and event['detail']['eventName'] == "CreateBucket": #Create bucket here we'll need touse boto3 to do a describe and read the tags.
        bucket_name = event['detail']['requestParameters']['bucketName']
        client = boto3.client('s3')
        response = client.get_bucket_tagging(
            Bucket=bucket_name
        )
        tags_val = response['TagSet']
        for tag in tags_val:
                log.debug(tag['Key'])
                if tag["Key"] in required_keys:
                    pre_keys.append(tag["Key"])

 
    #Lambda
    if bool(event) == True and event['detail']['eventName'] == "CreateFunction20150331":
        tags_val = event['detail']['requestParameters']['tags']
        for tag in tags_val:
                log.debug(tag)
                if tag in required_keys:
                    pre_keys.append(tag)


 
    for key in required_keys:
        if key not in pre_keys:
            missing_keys.append(key)

 
    if missing_keys:
        log.critical("Key/s not present")
        send_key_violation(event, missing_keys)
    else:
        return None
           

 
def get_instance_id(events):    
    arr = events['detail']['responseElements']['instancesSet']['items'][0]['instanceId'].split('/')
    return arr[-1]


 
#Need to update this
def send_key_violation(event, missing_keys):
    findsnsregion = outbound_topic_arn.split(":")
    snsregion = findsnsregion[3]
    sendclient = boto3.client('sns', region_name=snsregion)
    missing_keys = ', '.join(missing_keys)
    try:
        sendclient.publish(
            TopicArn=outbound_topic_arn,
            Message=("ec2 instance with instance-id :" + get_instance_id(event) + " in the region " +
                     snsregion + " is missing values: " + missing_keys),
            Subject="new - EC2 intances missing tags!"
        )
    except ClientError as err:
        log.error(err)
        return False


 
def send_null_violation(event):
    findsnsregion = outbound_topic_arn.split(":")
    snsregion = findsnsregion[3]
    sendclient = boto3.client('sns', region_name=snsregion)
    try:
        sendclient.publish(
            TopicArn=outbound_topic_arn,
            Message=("ec2 instance with instance-id :" + get_instance_id(event) + " in the region " +
                     snsregion + " has no Tag Values / NULL TAGS"),
            Subject="newViolation - EC2 intances missing tags!"
        )
    except ClientError as err:
        log.error(err)
        return False