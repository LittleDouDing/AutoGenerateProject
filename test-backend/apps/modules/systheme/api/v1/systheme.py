from fastapi import APIRouter, Depends
from sqlalchemy import select
from apps.ext.sqlalchemy import db_connect
from apps.ext.sqlalchemy.models import Systheme
from apps.modules.common.schemas.common import GetPageParams, GetParams
from apps.modules.systheme.schemas.systheme import GetSystheme, SysthemeSer
from apps.utils.crud import set_default_data
from apps.utils.pagination import Pagination
from apps.utils.response import Resp
from apps.utils.security import get_current_user_id

router = APIRouter(tags=["系统主题管理"])


@router.post('/addOne', summary="添加系统主题", response_model=Resp)
async def add_one(systheme: GetSystheme, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        systheme = Systheme(**systheme.dict())
        set_default_data(systheme, current_user_id)
        session.add(systheme)

        return Resp(message="添加系统主题信息成功")


@router.post('/deleteById/{id}', summary="删除系统主题", response_model=Resp)
async def delete_by_id(id: str):
    async with db_connect.async_session() as session:
        # 删除字典
        await session.execute(select(Systheme).where(Systheme.id == id).delete())

        return Resp(message="删除系统主题信息成功")


@router.post('/updateById/{id}', summary="更新系统主题", response_model=Resp)
async def update_by_id(id: str, systheme: GetSystheme, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        systheme = Systheme(**systheme.dict())
        systheme.id = id
        set_default_data(systheme, current_user_id)
        session.merge(systheme)

        return Resp(message="更新系统主题信息成功")


@router.get('/findById/{id}', summary="查询系统主题", response_model=Resp)
async def find_by_id(id: str):
    async with db_connect.async_session() as session:
        systheme = await session.get(Systheme, id)
        systheme_ser = SysthemeSer.dump(systheme)

        return Resp(data=systheme_ser, message="系统主题信息查询成功")


@router.get('/findList', summary="分页查询系统主题列表", response_model=Resp)
async def find_list(params: GetPageParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, Systheme).get_page(session)
        systheme_list = page_data['list']
        systheme_list = Systheme.dump(systheme_list, many=True)
        total = page_data['total']

        systheme = {"systhemeList": systheme_list, "total": total}
        return Resp(data=systheme, message="获取系统主题信息列表成功")


@router.get('/findAll', summary="查询所有系统主题", response_model=Resp)
async def find_all(params: GetParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, Systheme, all=True).get_page(session)
        systheme_list = page_data['list']
        systheme_list = SysthemeSer.dump(systheme_list, many=True)
        systheme = {"systhemeList": systheme_list}
        return Resp(data=systheme, message="获取系统主题信息列表成功")