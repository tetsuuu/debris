# shodan-verificator
SHODANで検出されたCVEが検証済みかを判断するためのスクリプト

# 実行方法

## CSVファイルから一括実行する場合
```bash
uv sync
. .venv/bin/activate
export SHODAN_API_KEY=""
export CSV_FILE_NAME="target.csv"
python verify_from_csv.py ${SHODAN_API_KEY} ${CSV_FILE_NAME}
deactivate
```

## IPを指定して実行する場合
```bash
uv sync
. .venv/bin/activate
export SHODAN_API_KEY=""
export HOST_IP="XXX.XXX.XXX.XXX"
python verify_specific_host.py ${SHODAN_API_KEY} ${HOST_IP}
deactivate
```

# 出力例
```bash
    ==== ホスト: XXX.XXX.XXX.XXX の脆弱性情報 ====

    OS: Ubuntu, Product: nginx, Version: 1.18.0
    HTTP Title: レンタルサーバ
    Component: All in One SEO Pack['2.11']
    Component: WordPress['4.9.26']

    CVE-2023-0585 はSHODANによってバージョン情報などのメタデータから推測されており、未検証です。
    Summary: The All in One SEO Pack plugin for WordPress is vulnerable to Stored Cross-Site Scripting via multiple parameters in versions up to, and including, 4.2.9 due to insufficient input sanitization and output escaping. This makes it possible for authenticated attackers with Administrator role or above to inject arbitrary web scripts in pages that will execute whenever a user accesses an injected page.
    CVSS Version: 3.0, Score: 4.4 (Severity: Medium)

    ------------------------------------------------------------------
```
