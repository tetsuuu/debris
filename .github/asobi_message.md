### Build Results {{ ":white_check_mark:" if status === "success" else ":cry:" }}

{{ actor }}! **{{ environment }}** の `{{ ref }}` ブランチビルドに{{ "成功" if status === "success" else "失敗" }}したよ!!

{% if environment_url %}You can view the deployment [here]({{ environment_url }}).{% endif %}
