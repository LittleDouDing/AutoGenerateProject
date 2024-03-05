{% if module_type == 'table' %}
export function add{{model_name}}(data: {{model_name}}Form) {
  return request({
    url: "/api/v1/{{table_name}}s",
    method: "post",
    data: data,
  });
}

export function update{{model_name}}(id: string, data: {{model_name}}Form) {
  return request({
    url: "/api/v1/{{table_name}}s/" + id,
    method: "put",
    data: data,
  });
}

export function delete{{model_name}}(id: number) {
  return request({
    url: "/api/v1/{{table_name}}s/" + id,
    method: "delete",
  });
}

export function get{{model_name}}Form(id: number): AxiosPromise<{{model_name}}Form> {
  return request({
    url: "/api/v1/{{table_name}}s/" + id + "/form",
    method: "get",
  });
}

export function getList{{model_name}}s(queryParams: {{model_name}}Query): AxiosPromise<{{model_name}}VO[]> {
  return request({
    url: "/api/v1/{{table_name}}s",
    method: "get",
    params: queryParams,
  });
}
{% endif %}

{% if need_file %}
export function export{{model_name}}(queryParams: {{model_name}}Query) {
  return request({
    url: "/api/v1/{{table_name}}s/export",
    method: "get",
    params: queryParams,
    responseType: "arraybuffer",
  });
}

export function import{{model_name}}(file: File) {
  const formData = new FormData();
  formData.append("file", file);
  return request({
    url: "/api/v1/{{table_name}}s/import",
    method: "post",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
}

export function downloadTemplate() {
  return request({
    url: "/api/v1/{{table_name}}s/template",
    method: "get",
    responseType: "arraybuffer",
  });
}
{% endif %}

{% if module_type == 'file' %}
export function uploadFileApi(file: File): AxiosPromise<FileInfo> {
  const formData = new FormData();
  formData.append("file", file);
  return request({
    url: "/api/v1/files",
    method: "post",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
}

export function deleteFileApi(filePath?: string) {
  return request({
    url: "/api/v1/files",
    method: "delete",
    params: { filePath: filePath },
  });
}
{% endif %}

{% if module_type == 'auth' %}
export function getCaptcha(): AxiosPromise<CaptchaResult> {
  return request({
    url: "/api/v1/auth/captcha",
    method: "get",
  });
}

export function logout() {
  return request({
    url: "/api/v1/auth/logout",
    method: "delete",
  });
}

export function login(data: LoginData): AxiosPromise<LoginResult> {
  const formData = new FormData();
  formData.append("username", data.username);
  formData.append("password", data.password);
  formData.append("captchaKey", data.captchaKey || "");
  formData.append("captchaCode", data.captchaCode || "");
  return request({
    url: "/api/v1/auth/login",
    method: "post",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
}
{% endif %}

{% if table_name == 'user' %}
export function getUserInfo(): AxiosPromise<UserInfo> {
  return request({
    url: "/api/v1/users/me",
    method: "get",
  });
}

export function updateUserPassword(id: number, password: string) {
  return request({
    url: "/api/v1/users/" + id + "/password",
    method: "patch",
    params: { password: password },
  });
}
{% endif %}

{% if table_name == 'role' %}
export function getRoleMenuIds(roleId: number): AxiosPromise<number[]> {
  return request({
    url: "/api/v1/roles/" + roleId + "/menuIds",
    method: "get",
  });
}

export function updateRoleMenus(
  roleId: number,
  data: number[]
): AxiosPromise<any> {
  return request({
    url: "/api/v1/roles/" + roleId + "/menus",
    method: "put",
    data: data,
  });
}
{% endif %}

{% if table_name == 'menu' %}
export function listRoutes() {
  return request({
    url: "/api/v1/menus/routes",
    method: "get",
  });
}
{% endif %}

{% if table_name in ['menu', 'dept', 'role', 'dict']  %}
export function get{{model_name}}Options(): AxiosPromise<OptionType[]> {
  return request({
    url: "/api/v1/{{table_name}}/options",
    method: "get",
  });
}
{% endif %}
