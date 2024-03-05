export const userRules = {
  username: [{ required: true, message: "用户名不能为空", trigger: "blur" }],
  nickname: [{ required: true, message: "用户昵称不能为空", trigger: "blur" }],
  deptId: [{ required: true, message: "所属部门不能为空", trigger: "blur" }],
  roleIds: [{ required: true, message: "用户角色不能为空", trigger: "blur" }],
  email: [
    {
      pattern: /\w[-\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\.)+[A-Za-z]{2,14}/,
      message: "请输入正确的邮箱地址",
      trigger: "blur",
    },
  ],
  mobile: [
    {
      pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/,
      message: "请输入正确的手机号码",
      trigger: "blur",
    },
  ],
};

export const queryObjects = [
  {
    prop: "keywords",
    label: "关键字",
    placeholder: "用户名/昵称/手机号",
    type: "input",
  },
  {
    prop: "status",
    label: "状态",
    options: [
      { label: "启用", value: 1 },
      { label: "禁用", value: 0 },
    ],
    type: "select",
  },
  { prop: "createTime", label: "创建时间", type: "dateRange" },
];

export const tableObjects = [
  { prop: "id", label: "编号" },
  { prop: "username", label: "用户名" },
  { prop: "nickname", label: "用户昵称" },
  { prop: "genderLabel", label: "性别" },
  { prop: "deptName", label: "部门" },
  { prop: "mobile", label: "手机号码" },
  { prop: "status", label: "状态", needTag: true },
  { prop: "createTime", label: "创建时间", width: 180 },
];
