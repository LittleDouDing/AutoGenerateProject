<template>
  <el-card shadow="never" class="table-container">
    <template #header>
      <div class="flex justify-between">
        <div>
          <el-button
            v-hasPerm="['sys:user:add']"
            type="success"
            @click="openDialog('user-form')"
            ><i-ep-plus />新增</el-button
          >
          <el-button
            v-hasPerm="['sys:user:delete']"
            type="danger"
            :disabled="removeIds.length === 0"
            @click="handleDelete()"
            ><i-ep-delete />删除</el-button
          >
        </div>
        <div>
          <el-dropdown split-button>
            导入
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="downloadTemplate">
                  <i-ep-download />下载模板
                </el-dropdown-item>
                <el-dropdown-item @click="openDialog('user-import')">
                  <i-ep-top />导入数据
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          <el-button class="ml-3" @click="handleExport">
            <template #icon> <i-ep-download /> </template>导出
          </el-button>
        </div>
      </div>
    </template>

    <el-table
      v-loading="loading"
      :data="pageData"
      @selection-change="handleSelectionChange"
    >
      <el-table-column
        v-if="needSelection"
        type="selection"
        width="50"
        align="center"
      />
      <el-table-column
        v-for="obj in tableObjects"
        :key="obj.prop"
        :prop="obj.prop"
        :label="obj.label"
        :align="obj.align || 'center'"
        :width="obj.width || 120"
      >
        <template v-if="obj.needTag" #default="{ row }">
          <el-tag :type="row[obj.prop] == 1 ? 'success' : 'info'"
            >{{ status[row[obj.prop]] }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" fixed="right" width="220">
        <template #default="{ row }">
          <!-- <el-button
            v-hasPerm="['sys:user:reset_pwd']"
            type="primary"
            size="small"
            link
            @click="resetPassword(row)"
          >
            <i-ep-refresh-left />
            重置密码
          </el-button> -->
          <el-button
            v-hasPerm="['sys:user:edit']"
            type="primary"
            link
            size="small"
            @click="openDialog('user-form', row.id)"
          >
            <i-ep-edit />编辑
          </el-button>
          <el-button
            v-hasPerm="['sys:user:delete']"
            type="primary"
            link
            size="small"
            @click="handleDelete(row.id)"
          >
            <i-ep-delete />删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>
<script setup lang="ts">
import { status } from "@/data/common";
const queryFormRef = ref(ElForm); // 查询表单

const props = defineProps({
  inline: { type: Boolean, default: true },
  loading: { type: Boolean, default: false },
  needSelection: { type: Boolean, default: true },
  queryParams: { type: Object },
  pageData: { type: Object },
  queryObjects: { type: Array(Object) },
  tableObjects: { type: Array(Object) },
});

const params = reactive({ ...props.queryParams });
const emit = defineEmits([
  "handleQuery",
  "resetQuery",
  "openDialog",
  "handleDelete",
]);

function handleQuery() {
  emit("handleQuery", params);
}

function resetQuery() {
  queryFormRef.value.resetFields();
  emit("resetQuery");
}
function openDialog() {
  emit("openDialog");
}
function handleDelete() {
  emit("handleDelete");
}
</script>
