from fastapi import APIRouter, Depends
from sqlalchemy import select
from apps.ext.sqlalchemy import db_connect
from apps.ext.sqlalchemy.models import {{model_name}}
from apps.modules.common.schemas.common import GetPageParams, GetParams
from apps.modules.{{table_name}}.schemas.{{table_name}} import Get{{model_name}}, {{model_name}}Ser
from apps.utils.crud import set_default_data
from apps.utils.pagination import Pagination
from apps.utils.response import Resp
from apps.utils.security import get_current_user_id

router = APIRouter(tags=["{{table_commit}}管理"])


@router.post('/addOne', summary="添加{{table_commit}}", response_model=Resp)
async def add_one({{table_name}}: Get{{model_name}}, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        {{table_name}} = {{model_name}}(**{{table_name}}.dict())
        set_default_data({{table_name}}, current_user_id)
        session.add({{table_name}})

        return Resp(message="添加{{table_commit}}信息成功")


@router.post('/deleteById/{id}', summary="删除{{table_commit}}", response_model=Resp)
async def delete_by_id(id: str):
    async with db_connect.async_session() as session:
        # 删除字典
        await session.execute(select({{model_name}}).where({{model_name}}.id == id).delete())

        return Resp(message="删除{{table_commit}}信息成功")


@router.post('/updateById/{id}', summary="更新{{table_commit}}", response_model=Resp)
async def update_by_id(id: str, {{table_name}}: Get{{model_name}}, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        {{table_name}} = {{model_name}}(**{{table_name}}.dict())
        {{table_name}}.id = id
        set_default_data({{table_name}}, current_user_id)
        session.merge({{table_name}})

        return Resp(message="更新{{table_commit}}信息成功")


@router.get('/findById/{id}', summary="查询{{table_commit}}", response_model=Resp)
async def find_by_id(id: str):
    async with db_connect.async_session() as session:
        {{table_name}} = await session.get({{model_name}}, id)
        {{table_name}}_ser = {{model_name}}Ser.dump({{table_name}})

        return Resp(data={{table_name}}_ser, message="{{table_commit}}信息查询成功")


@router.get('/findList', summary="分页查询{{table_commit}}列表", response_model=Resp)
async def find_list(params: GetPageParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, {{model_name}}).get_page(session)
        {{table_name}}_list = page_data['list']
        {{table_name}}_list = {{model_name}}.dump({{table_name}}_list, many=True)
        total = page_data['total']

        {{table_name}} = {"{{table_name}}List": {{table_name}}_list, "total": total}
        return Resp(data={{table_name}}, message="获取{{table_commit}}信息列表成功")


@router.get('/findAll', summary="查询所有{{table_commit}}", response_model=Resp)
async def find_all(params: GetParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, {{model_name}}, all=True).get_page(session)
        {{table_name}}_list = page_data['list']
        {{table_name}}_list = {{model_name}}Ser.dump({{table_name}}_list, many=True)
        {{table_name}} = {"{{table_name}}List": {{table_name}}_list}
        return Resp(data={{table_name}}, message="获取{{table_commit}}信息列表成功")