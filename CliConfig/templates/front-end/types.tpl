{% if module_type == 'table' %}
export interface {{model_name}}Form {
  {% for key, value in DataForm.items() %}
  {{key}}?: {{value}}
  {% endfor %}
  {% if table_name == 'user' %}
  roleIds?: number[];
  {% endif %}
}

export interface {{model_name}}PageVO {
  {% for key, value in DataForm.items() %}
  {{key}}?: {{value}}
  {% endfor %}
  {% if table_name == 'user' %}
  roleIds?: number[];
  {% endif %}
}
{% endif %}

{% if module_type == 'file' %}
export interface FileInfo {
  name: string;
  url: string;
}
{% endif %}
