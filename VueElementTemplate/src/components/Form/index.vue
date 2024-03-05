<template>
  <div class="search-container">
    <el-form ref="queryFormRef" :model="params" :inline="inline">
      <el-form-item
        v-for="obj in queryObjects"
        :key="obj.prop"
        :label="obj.label"
        :prop="obj.prop"
      >
        <el-input
          clearable
          v-if="obj.type === 'input'"
          v-model="params[obj.prop]"
          :style="{ width: `${obj.width || 200}px` }"
          :placeholder="obj.placeholder"
          @keyup.enter="handleQuery"
        />
        <el-select
          clearable
          v-else-if="obj.type === 'select'"
          v-model="params[obj.prop]"
          placeholder="默认全部"
          :class="`!w-[${obj.width || 100}px]`"
        >
          <el-option
            v-for="option in obj.options"
            :key="option.label"
            :label="option.label"
            :value="option.value"
          />
        </el-select>
        <el-date-picker
          v-else-if="obj.type === 'dateRange'"
          v-model="params[obj.prop]"
          type="daterange"
          :class="`!w-[${obj.width || 240}px]`"
          range-separator="~"
          start-placeholder="开始时间"
          end-placeholder="截止时间"
          value-format="YYYY-MM-DD"
        />
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="handleQuery">
          <i-ep-search />
          搜索
        </el-button>
        <el-button @click="resetQuery">
          <i-ep-refresh />
          重置
        </el-button>
      </el-form-item>
    </el-form>
  </div>
</template>
<script setup lang="ts">
const queryFormRef = ref(ElForm); // 查询表单

const props = defineProps({
  inline: { type: Boolean, default: true },
  queryParams: { type: Object },
  queryObjects: { type: Array(Object) },
});
const params = reactive({ ...props.queryParams });
const emit = defineEmits(["handleQuery", "resetQuery"]);

function handleQuery() {
  emit("handleQuery", params);
}

function resetQuery() {
  queryFormRef.value.resetFields();
  emit("resetQuery");
}
</script>
