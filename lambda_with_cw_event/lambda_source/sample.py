# coding=utf-8
import json
import logging
import os
import re
import datetime
import calendar
import boto3
import requests

# slackの設定
slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
slack_channel = os.environ['SLACK_CHANNEL']
color = os.environ['COLOR'] if 'COLOR' in os.environ else 'warning'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# 抽出するログデータの最大件数
maximum_logs = int(os.environ['MAXIMUM_LOGS'])
# 何分前までを抽出対象期間とするか
time_range = 5


def lambda_handler(event, context):
    logger.info("Event: {}".format(event))
    message = json.loads(event['Records'][0]['Sns']['Message'])
    alarm_name = message['AlarmName']

    logs = boto3.client('logs')

    # MetricNameとNamespaceをキーにメトリクスフィルタの情報を取得する。
    metric_filters = logs.describe_metric_filters(
        metricName=message['Trigger']['MetricName'],
        metricNamespace=message['Trigger']['Namespace']
    )

    logger.info("Metric Filters: {}".format(metric_filters))

    # 終了時刻はアラーム発生時刻の1分後
    time_to = datetime.datetime.strptime(message['StateChangeTime'][:19], '%Y-%m-%dT%H:%M:%S') + datetime.timedelta(
        minutes=1)
    end_to = calendar.timegm(time_to.utctimetuple()) * 1000
    # 開始時刻は終了時刻のtime_range分前
    time_from = time_to - datetime.timedelta(minutes=time_range)
    start_from = calendar.timegm(time_from.utctimetuple()) * 1000

    # ログストリームからログデータを取得
    mti_logs = logs.filter_log_events(
        logGroupName=metric_filters['metricFilters'][0]['logGroupName'],
        filterPattern=metric_filters['metricFilters'][0]['filterPattern'],
        startTime=start_from,
        endTime=end_to,
        limit=maximum_logs
    )

    logger.info("Filter Log Events: {}".format(mti_logs))

    # メッセージを整形しつつslackに通知

    for event in mti_logs['events']:
        log_message = event['message']
        pan = re.search(r'pan: ([\*]+)(?P<pan>[0-9]+)', log_message)

        timestamp = re.search(
            r'Timestamp: \{ month: (?P<mth>[0-9]+), day_of_month: (?P<day>[0-9]+),'
            r' hour: (?P<hrs>[0-9]+), minute: (?P<min>[0-9]+), second: (?P<sec>[0-9]+) \}'
            , log_message
        )

        now = datetime.datetime.now()
        dt = datetime.datetime(
            now.year,
            int(timestamp.group('mth')),
            int(timestamp.group('day')),
            int(timestamp.group('hrs')),
            int(timestamp.group('min')),
            int(timestamp.group('sec'))
        )
        jst_timestamp = dt + datetime.timedelta(hours=9)

        amount = re.search(r'Amount \{ amount: (?P<amount>[0-9]+)', log_message)

        currency = re.search(r'Currency \{ currency: (?P<currency>[0-9]+)', log_message)

        acceptor_record = re.search(r'acceptor: \[(?P<acceptor>[a-zA-Z0-9,\s]+)+\]', log_message)
        acceptor = Translater.readable(acceptor_record.group('acceptor'))

        city_record = re.search(r'city: \[(?P<city>[a-zA-Z0-9,\s]+)+\]', log_message)
        city = Translater.readable(city_record.group('city'))

        number_record = re.search(r'Number: (?P<num>[a-zA-Z0-9,\s]+)+\]\)', log_message)
        number = re.findall(r'[0-9]', number_record.group('num'))

        logger.info(
            'Sanitized PAN: {}, Transaction Date: {}, Transaction Amount: {}, Currency Code: {},'
            ' Acceptor Name: {}, City Name: {}, Retrieval Reference Number: {}'.format(
                pan.group('pan'), jst_timestamp, amount.group('amount'),currency.group('currency'), acceptor, city, number
            )
        )

        slack_message = {
            'channel': slack_channel,
            'attachments': [
                {
                    'color': color,
                    'title': alarm_name,
                    'fields': [
                        {
                            'title': 'Sanitized PAN',
                            'value': pan.group('pan'),
                            'short': True,
                        },
                        {
                            'title': 'Transaction Date',
                            'value': str(jst_timestamp),
                            'short': True,
                        },
                        {
                            'title': 'Transaction Amount',
                            'value': amount.group('amount'),
                            'short': True,
                        },
                        {
                            'title': 'Currency Code',
                            'value': currency.group('currency'),
                            'short': True,
                        },
                        {
                            'title': 'Merchant Name',
                            'value': ''.join(acceptor),
                            'short': True,
                        },
                        {
                            'title': 'City Name',
                            'value': ''.join(city),
                            'short': True,
                        },
                        {
                            'title': 'Retrieval Reference Number',
                            'value': ''.join(number),
                            'short': False,
                        }
                    ],
                    'footer': 'AWS CloudWatch Alarm',
                    'ts': event['timestamp'] / 1000
                }
            ]
        }

        response = requests.post(
            slack_webhook_url,
            data=json.dumps(slack_message)
        )
        logger.info("Response: {}".format(response))


class Translater:
    char_dict = {
        "Space": " ",
        "Period": ".",
        "LessThan": "<",
        "Plus": "+",
        "Exclamation": "!",
        "Semicolon": ";",
        "Hyphen": "-",
        "Slash": "/",
        "Comma": ",",
        "Percent": "%",
        "UnderScore": "_",
        "GreaterThan": ">",
        "Question": "?",
    }
    letter_list = []
    letters = []

    def __init__(self):
        self.letter_list = []
        self.letters = []

    @classmethod
    def readable(cls, text):
        for i, char_tuple in enumerate(cls.char_dict.items()):
            text = text.replace(char_tuple[0], '{' + str(i) + '}')
            cls.letter_list.append(char_tuple[1])

        cls.letters = []
        for text_list in text.split(','):
            single_letter = text_list.format(*cls.letter_list)
            cls.letters.append(single_letter)

        logger.info("Translated Text: {}".format(cls.letters))

        return cls.letters
