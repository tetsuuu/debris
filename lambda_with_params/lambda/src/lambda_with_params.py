# coding=utf-8
import json
import os
import time
import boto3

from botocore.vendored import requests

stage = os.environ['STAGE']
# Slackの設定
slackWebhookUrl = os.environ['SLACK_WEBHOOK_URL']
slackChannel = os.environ['SLACK_CHANNEL']
messageColor = 'warning'
# APIの設定
secretKey = os.environ['SECRET_KEY_NAME']
defaultPath = os.environ['BASE_RECORD']
targetApi = os.environ['API_PATH']


def lambda_handler(event, context):
    print(event)

    ssm = boto3.client('ssm')
    url = '{}{}'.format(defaultPath, targetApi)
    print(url)

    getSecretDetail = ssm.get_parameter(
        Name = secretKey,
        WithDecryption = True
    )

    secretValue = getSecretDetail['Parameter']['Value']

    header = {
        'secret': secretValue
    }

    resp = requests.post(url, headers=header)

    print(resp.status_code, resp.text)

    timeStamp = int(time.time())
    messageColor = 'good' if 200 == resp.status_code else messageColor

    slackMessage = {
        'channel': slackChannel,
        'text': ' `{}` 実行結果({})'.format(targetApi, stage),
        'attachments': [
            {
                'color': messageColor,
                'fields': [
                    {
                        'title': 'Status',
                        'value': resp.status_code,
                        'short': False,
                    },
                    {
                        'title': 'Result',
                        'value': resp.text,
                        'short': False,
                    }
                ],
                'footer': 'Amazon CloudWatch Events',
                'ts': timeStamp
            }
        ]
    }

    response = requests.post(
        slackWebhookUrl,
        data=json.dumps(slackMessage)
    )

    print(response.status_code)
    print(response.text)
