import shodan
import argparse
import csv


def get_severity(cvss_score):
    """CVSSスコアからSeverityを判定する関数"""
    if cvss_score is None:
        return "不明"
    elif cvss_score >= 9.0:
        return "Critical"
    elif cvss_score >= 7.0:
        return "High"
    elif cvss_score >= 4.0:
        return "Medium"
    else:
        return "Low"

def main():
    parser = argparse.ArgumentParser(description="CSVファイルからホストIPとCVE IDを読み取り、Shodanで脆弱性情報を確認します。")
    parser.add_argument("api_key", help="Shodan APIキー")
    parser.add_argument("csv_file", help="ホストIPとCVE IDが記載されたCSVファイルのパス")
    args = parser.parse_args()

    api_key = args.api_key
    csv_file_path = args.csv_file

    api = shodan.Shodan(api_key)

    try:
        with open(csv_file_path, 'r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                host_ip = row['host_ip'].strip()
                cve_id = row['cve_id'].strip()
                print(f"\n    ==== ホスト: {host_ip} の脆弱性情報 ====\n")

                try:
                    # 特定のIPアドレスの情報を取得
                    host = api.host(host_ip)

                    if 'data' in host and isinstance(host['data'], list):
                        found_vuln = False
                        for service_data in host['data']:
                            version = service_data.get('version')
                            if version is None or str(version).lower() == 'none':
                                version = '不明'
                            product = service_data.get('product', 'なし')
                            os_info = service_data.get('os')
                            if os_info is None or str(os_info).lower() == 'none':
                                os_info = '不明'
                            http_title = 'なし'
                            if 'http' in service_data and isinstance(service_data['http'], dict):
                                title = service_data['http'].get('title')
                                if title is not None and title != "":
                                    http_title = title
                                if 'components' in service_data['http'] and isinstance(service_data['http']['components'], dict):
                                    components = service_data['http']['components']
                                    for component_name, component_info in components.items():
                                        if isinstance(component_info, dict) and 'versions' in component_info:
                                            versions = component_info.get('versions')
                                            print(f"    Component: {component_name}{versions}")
                            print(f"    OS: {os_info}, Product: {product}, Version: {version}")
                            print(f"    HTTP Title: {http_title}")
                            if 'vulns' in service_data and isinstance(service_data['vulns'], dict) and cve_id in service_data['vulns']:
                                found_vuln = True
                                vuln_info = service_data['vulns'][cve_id]
                                is_verified = vuln_info.get('verified', False)
                                cvss = vuln_info.get('cvss')
                                cvss_version = vuln_info.get('cvss_version')
                                severity = get_severity(cvss)
                                summary = vuln_info.get('summary', 'なし')

                                verification_status = "検証されています" if is_verified else "バージョン情報などのメタデータから推測されており、未検証です"
                                print(f"\n    {cve_id} はSHODANによって{verification_status}。")
                                print(f"    Summary: {summary}")
                                if cvss is not None and cvss_version is not None:
                                    print(f"    CVSS Version: {cvss_version}, Score: {cvss} (Severity: {severity})\n")
                                    print(f"    ------------------------------------------------------------------\n")
                                elif cvss is not None:
                                    print(f"    CVSS Score: {cvss} (Severity: {severity})\n")
                                    print(f"    ------------------------------------------------------------------\n")
                                elif cvss_version is not None:
                                    print(f"    CVSS Version: {cvss_version}\n")
                                    print(f"    ------------------------------------------------------------------\n")
                                else:
                                    print(f"    CVSSスコアの情報はありません。\n")
                                    print(f"    ------------------------------------------------------------------\n")
                                break
                        if not found_vuln:
                            print(f"    {cve_id} の情報はSHODANで見つかりませんでした。\n")
                            print(f"    ------------------------------------------------------------------\n")
                    else:
                        print(f"    ホストのデータ形式が予期しない形式です。\n")

                except shodan.APIError as e:
                    print(f"  Shodan APIエラー: {e}")
                except Exception as e:
                    print(f"  予期せぬエラーが発生しました: {e}")

    except FileNotFoundError:
        print(f"エラー: CSVファイル '{csv_file_path}' が見つかりません。")
    except Exception as e:
        print(f"予期せぬエラーが発生しました: {e}")

if __name__ == "__main__":
    main()
