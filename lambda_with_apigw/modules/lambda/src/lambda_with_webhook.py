# coding=utf-8
import datetime
import os
import json
import re
import requests
import boto3

# Test Data
# 'body':
# [
#   {
#     "email":"example@test.com",
#     "timestamp":1614744922,
#     "smtp-id":"\\u003c14c5d75ce93.dfd.64b469@ismtpd-555\\u003e",
#     "event":"deferred",
#     "category":["cat facts"],
#     "sg_event_id":"WdSdrEJfBVaejVcbc31wfw==",
#     "sg_message_id":"14c5d75ce93.dfd.64b469.filter0001.16648.5515E0B88.0",
#     "response":"400 try again later",
#     "attempt":"5"
#   },
#   {
#     "email":"example@test.com",
#     "timestamp":1614744922,
#     "smtp-id":"\\u003c14c5d75ce93.dfd.64b469@ismtpd-555\\u003e",
#     "event":"bounce",
#     "category":["cat facts"],
#     "sg_event_id":"eRUn81vb8ryVmVmOftGD_w==",
#     "sg_message_id":"14c5d75ce93.dfd.64b469.filter0001.16648.5515E0B88.0",
#     "reason":"500 unknown recipient",
#     "status":"5.0.0"
#   },
#   {
#     "email":"example@test.com",
#     "timestamp":1614744922,
#     "smtp-id":"\\u003c14c5d75ce93.dfd.64b469@ismtpd-555\\u003e",
#     "event":"dropped",
#     "category":["cat facts"],
#     "sg_event_id":"lj0DtyN_RlC3z4qd-Ik84Q==",
#     "sg_message_id":"14c5d75ce93.dfd.64b469.filter0001.16648.5515E0B88.0",
#     "reason":"Bounced Address",
#     "status":"5.0.0"
#   }
# ]


def lambda_handler(event, context):
    body = event['body']

    print('Events : {}'.format(body))

    event_dict = json.loads(body)
    post_message(event_dict)


def post_message(message):
    slack_channel = os.environ['SLACK_CHANNEL']
    slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']

    for text in message:
        email = text['email']
        status = text['event']
        utc_ts = text['timestamp']
        tokyo_ts = utc_ts + 32400
        attempt = datetime.datetime.fromtimestamp(tokyo_ts)
        masked_email = re.sub(r'^[0-9a-z_./?-]+@', '******@', email)
        if status == 'deferred':
            reason = text['response']
        elif status == 'bounce' or status == 'dropped':
            reason = text['reason']
        else:
            reason = '要確認'

        slack_message = {
            'channel': slack_channel,
            'attachments': [
                {
                    'color': 'warn',
                    'username': ':SendGrid:',
                    'icon_emoji': ':sendgrid:',
                    'title': 'SendGrid {} 検知'.format(status),
                    'fields': [
                        {
                            'title': 'ステータス',
                            'value': status,
                            'short': True,
                        },
                        {
                            'title': '発生日時',
                            'value': attempt,
                            'short': True,
                        },
                        {
                            'title': '対象',
                            'value': masked_email,
                            'short': True,
                        },
                        {
                            'title': 'メッセージ',
                            'value': reason,
                            'short': True,
                        }
                    ],
                    'footer': 'SendGrid',
                    'ts': tokyo_ts
                }
            ]
        }

        response = requests.post(
            slack_webhook_url,
            data=json.dumps(slack_message)
        )

        return response
