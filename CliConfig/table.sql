
CREATE TABLE dept (
	id BIGINT NOT NULL COMMENT '主键id' DEFAULT (uuid()), 
	name VARCHAR(64) NOT NULL COMMENT '部门名称', 
	parent_id BIGINT NOT NULL COMMENT '父节点id', 
	tree_path VARCHAR(256) COMMENT '父节点id路径', 
	status TINYINT(1) NOT NULL COMMENT '状态(0:正常;1:禁用)', 
	deleted TINYINT(1) COMMENT '逻辑删除标识(1:已删除;0:未删除)', 
	create_user BIGINT NOT NULL COMMENT '创建人的id', 
	update_user BIGINT NOT NULL COMMENT '创建人的id', 
	create_time DATETIME NOT NULL COMMENT '创建时间', 
	update_time DATETIME NOT NULL COMMENT '更新时间', 
	PRIMARY KEY (id)
)ENGINE=InnoDB COLLATE utf8mb4_0900_ai_ci DEFAULT CHARSET=utf8mb4


CREATE TABLE dict (
	id BIGINT NOT NULL COMMENT '主键id' DEFAULT (uuid()), 
	type_code VARCHAR(64) COMMENT '字典类型编码', 
	name VARCHAR(50) COMMENT '字典名称', 
	value VARCHAR(50) COMMENT '字典值', 
	status TINYINT(1) COMMENT '状态(1:启用;0:禁用)', 
	defaulted TINYINT(1) COMMENT '是否默认(1:是;0:否)', 
	remark VARCHAR(256) COMMENT '备注', 
	create_user BIGINT NOT NULL COMMENT '创建人的id', 
	update_user BIGINT NOT NULL COMMENT '创建人的id', 
	create_time DATETIME NOT NULL COMMENT '创建时间', 
	update_time DATETIME NOT NULL COMMENT '更新时间', 
	PRIMARY KEY (id)
)ENGINE=InnoDB COLLATE utf8mb4_0900_ai_ci DEFAULT CHARSET=utf8mb4


CREATE TABLE dict_type (
	id BIGINT NOT NULL COMMENT '主键id' DEFAULT (uuid()), 
	name VARCHAR(50) COMMENT '类型名称', 
	code VARCHAR(50) COMMENT '类型编码', 
	status TINYINT(1) COMMENT '状态(0:正常;1:禁用)', 
	remark VARCHAR(256) COMMENT '备注', 
	create_user BIGINT NOT NULL COMMENT '创建人的id', 
	update_user BIGINT NOT NULL COMMENT '创建人的id', 
	create_time DATETIME NOT NULL COMMENT '创建时间', 
	update_time DATETIME NOT NULL COMMENT '更新时间', 
	PRIMARY KEY (id)
)ENGINE=InnoDB COLLATE utf8mb4_0900_ai_ci DEFAULT CHARSET=utf8mb4


CREATE TABLE menu (
	id BIGINT NOT NULL COMMENT '主键id' DEFAULT (uuid()), 
	parent_id TINYINT(1) NOT NULL COMMENT '父菜单ID', 
	tree_path VARCHAR(256) COMMENT '父节点ID路径', 
	name VARCHAR(64) NOT NULL COMMENT '菜单名称', 
	type TINYINT(1) NOT NULL COMMENT '菜单类型(1:菜单 2:目录 3:外链 4:按钮)', 
	path VARCHAR(128) COMMENT '路由路径(浏览器地址栏路径)', 
	component VARCHAR(128) COMMENT '组件路径(vue页面完整路径，省略.vue后缀)', 
	perm VARCHAR(128) COMMENT '权限标识', 
	visible TINYINT(1) NOT NULL COMMENT '显示状态(1-显示;0-隐藏)', 
	icon VARCHAR(64) COMMENT '菜单图标', 
	redirect VARCHAR(128) COMMENT '跳转路径', 
	always_show TINYINT(1) COMMENT '【目录】只有一个子路由是否始终显示(1:是 0:否)', 
	keep_alive TINYINT(1) COMMENT '【菜单】是否开启页面缓存(1:是 0:否)', 
	create_user BIGINT NOT NULL COMMENT '创建人的id', 
	update_user BIGINT NOT NULL COMMENT '创建人的id', 
	create_time DATETIME NOT NULL COMMENT '创建时间', 
	update_time DATETIME NOT NULL COMMENT '更新时间', 
	PRIMARY KEY (id)
)ENGINE=InnoDB COLLATE utf8mb4_0900_ai_ci DEFAULT CHARSET=utf8mb4


CREATE TABLE `role` (
	id BIGINT NOT NULL COMMENT '主键id' DEFAULT (uuid()), 
	name VARCHAR(64) NOT NULL COMMENT '角色名称', 
	code VARCHAR(32) COMMENT '角色编码', 
	status TINYINT(1) COMMENT '角色状态(1-正常；0-停用)', 
	data_scope TINYINT(1) COMMENT '数据权限(0-所有数据；1-部门及子部门数据；2-本部门数据；3-本人数据)', 
	deleted TINYINT(1) COMMENT '逻辑删除标识(0-未删除；1-已删除)', 
	create_user BIGINT NOT NULL COMMENT '创建人的id', 
	update_user BIGINT NOT NULL COMMENT '创建人的id', 
	create_time DATETIME NOT NULL COMMENT '创建时间', 
	update_time DATETIME NOT NULL COMMENT '更新时间', 
	PRIMARY KEY (id)
)ENGINE=InnoDB COLLATE utf8mb4_0900_ai_ci DEFAULT CHARSET=utf8mb4


CREATE TABLE user (
	id BIGINT NOT NULL COMMENT '主键id' DEFAULT (uuid()), 
	username VARCHAR(64) COMMENT '用户名', 
	password VARCHAR(100) COMMENT '用户密码', 
	nickname VARCHAR(64) COMMENT '用户昵称', 
	gender TINYINT(1) COMMENT '性别((1:男;2:女))', 
	mobile VARCHAR(20) COMMENT '联系方式', 
	email VARCHAR(256) COMMENT '邮箱', 
	`deptName` VARCHAR(128) COMMENT '所属部门', 
	avatar VARCHAR(256) COMMENT '用户头像', 
	status TINYINT(1) COMMENT '用户状态((1:正常;0:禁用))', 
	dept_id BIGINT COMMENT '部门ID', 
	deleted TINYINT(1) COMMENT '逻辑删除标识(0:未删除;1:已删除)', 
	create_user BIGINT NOT NULL COMMENT '创建人的id', 
	update_user BIGINT NOT NULL COMMENT '创建人的id', 
	create_time DATETIME NOT NULL COMMENT '创建时间', 
	update_time DATETIME NOT NULL COMMENT '更新时间', 
	PRIMARY KEY (id)
)ENGINE=InnoDB COLLATE utf8mb4_0900_ai_ci DEFAULT CHARSET=utf8mb4

