export function addOneTABLENAMEToUpperCase(data) {
  return request({
    url: '/{{table_name}}/addOne',
    method: 'post',
    data
  })
}

export function deleteByIdTABLENAMEToUpperCase(id) {
  return request({
    url: '/{{table_name}}/deleteById/' + id,
    method: 'post'
  })
}

export function updateByIdTABLENAMEToUpperCase(id, data) {
  return request({
    url: '/{{table_name}}/updateById/' + id,
    method: 'post',
    data
  })
}

export function findByIdTABLENAMEToUpperCase(id) {
  return request({
    url: '/{{table_name}}/findById/' + id,
    method: 'get'
  })
}

export function findListTABLENAMEToUpperCase(params) {
  return request({
    url: '/{{table_name}}/findList',
    method: 'get',
    params
  })
}

export function findAllTABLENAMEToUpperCase(params) {
  return request({
    url: '/{{table_name}}/findAll',
    method: 'get',
    params
  })
}