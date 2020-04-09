# coding=utf-8
import json
import os
import datetime

from botocore.vendored import requests


# Event Format from S3 event
#
# Records[]
# {
#     'eventVersion': '2.1',
#     'eventSource': 'aws:s3',
#     'awsRegion': 'ap-northeast-1',
#     'eventTime': '2020-04-08T10:50:53.466Z',
#     'eventName': 'ObjectCreated:Put',
#     'userIdentity': {
#         'principalId': 'AWS:AIDA2O6A4QBJQGJUYZIC2'
#     },
#     'requestParameters': {
#         'sourceIPAddress': 'XX.XX.XX.XX'
#     },
#     'responseElements': {
#         'x-amz-request-id': '2F7D9423793C3E16',
#         'x-amz-id-2': 'cDJqkXcG0M/TGpzZBu0xBYnH2o8ZIFVzd8ti1d5Grrlqw0iJ9H0X7SLVRGQOpmZU98ye0VAGbIugQydGlhxcfHMoIcZmpic4'
#     },
#     's3': {
#         's3SchemaVersion': '1.0',
#         'configurationId': 'sample_event',
#         'bucket': {
#             'name': 'this-is-sample',
#             'ownerIdentity': {
#                 'principalId': 'A1SB66N1WQINOZ'
#             },
#             'arn': 'arn:aws:s3:::this-is-sample'
#         },
#         'object': {
#             'key': 'sample.file',
#             'size': 56,
#             'eTag': '86c482f608c8a417d5a9b59b957eedc0',
#             'sequencer': '005E8DAC8DCC5956A7'
#         }
#     }
# }

def lambda_handler(event, context):
    print(event)

    slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
    for record in event['Records']:
        payload = format_record_to_slack_message(record)
        resp = requests.post(
            slack_webhook_url,
            data=json.dumps(payload)
        )

        print(resp.status_code)
        print(resp.text)


def format_record_to_slack_message(record):
    print(record)

    eventTime = datetime.datetime.strptime(record['eventTime'][:19], '%Y-%m-%dT%H:%M:%S') + datetime.timedelta(hours=9)
    occurredTime = str(eventTime)
    eventAction = record['eventName']
    region = record['awsRegion']
    subject = record['s3']['configurationId']

    bucketInfo = record['s3']['bucket']
    objectInfo = record['s3']['object']

    logBucket = bucketInfo['name']
    objectKey = objectInfo['key']

    color = os.environ['COLOR'] if 'COLOR' in os.environ else 'warning'
    slack_channel = os.environ['SLACK_CHANNEL']

    slack_message = {
        'channel': slack_channel,
        'attachments': [
            {
                'color': color,
                'title': subject,
                'text': 'SFTP Error from toppan',
                'fields': [
                    {
                        'title': 'EventName',
                        'value': eventAction,
                        'short': True,
                    },
                    {
                        'title': 'EventTime',
                        'value': occurredTime,
                        'short': True,
                    },
                    {
                        'title': 'Bucket',
                        'value': logBucket,
                        'short': False,
                    },
                    {
                        'title': 'Region',
                        'value': region,
                        'short': True,
                    },
                    {
                        'title': 'Object',
                        'value': objectKey,
                        'short': True,
                    }
                ],
                'footer': 'Amazon S3 Event'
            }
        ]
    }

    return slack_message
