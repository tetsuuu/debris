### Build Results {{ ":white_check_mark:" if status === "success" else ":cry:" }}

{{ actor }} build branch `{{ ref }}` for **{{ environment }}**. This build was a {{ status }} {{ ":white_check_mark:" if status === "success" else ":cry:" }}.

{% if environment_url %}You can view the deployment [here]({{ environment_url }}).{% endif %}
