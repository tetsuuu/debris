import shodan
import argparse


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
    parser = argparse.ArgumentParser(description="指定されたホストIPアドレスに紐づくすべての脆弱性情報をShodanで確認します。")
    parser.add_argument("api_key", help="Shodan APIキー")
    parser.add_argument("host_ip", help="対象のホストIPアドレス")
    args = parser.parse_args()

    api_key = args.api_key
    host_ip = args.host_ip

    api = shodan.Shodan(api_key)

    print(f"\n    ==== ホスト: {host_ip} の脆弱性情報 ====\n")

    try:
        # 特定のIPアドレスの情報を取得
        host = api.host(host_ip)

        if 'data' in host and isinstance(host['data'], list):
            found_any_vuln = False
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
                print(f"    HTTP Title: {http_title}\n")

                if 'vulns' in service_data and isinstance(service_data['vulns'], dict):
                    found_vuln_in_service = False
                    for cve_id, vuln_info in service_data['vulns'].items():
                        found_any_vuln = True
                        found_vuln_in_service = True
                        is_verified = vuln_info.get('verified', False)
                        cvss = vuln_info.get('cvss')
                        cvss_version = vuln_info.get('cvss_version')
                        severity = get_severity(cvss)
                        summary = vuln_info.get('summary', 'なし')

                        verification_status = "検証されています" if is_verified else "バージョン情報などのメタデータから推測されており、未検証です"
                        print(f"\n    CVE: {cve_id} はSHODANによって{verification_status}。")
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

                    if not found_vuln_in_service:
                        print("    このサービスには特定の脆弱性情報は見つかりませんでした。\n")
                        print(f"    ------------------------------------------------------------------\n")
                else:
                    print("    このサービスには脆弱性情報が見つかりませんでした。\n")
                    print(f"    ------------------------------------------------------------------\n")

            if not found_any_vuln:
                print("    このホスト全体で脆弱性情報は見つかりませんでした。\n")

        else:
            print(f"    ホストのデータ形式が予期しない形式です。\n")

    except shodan.APIError as e:
        print(f"  Shodan APIエラー: {e}")
    except Exception as e:
        print(f"  予期せぬエラーが発生しました: {e}")

if __name__ == "__main__":
    main()
