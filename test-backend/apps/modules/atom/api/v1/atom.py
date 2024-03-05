from fastapi import APIRouter, Depends
from sqlalchemy import select
from apps.ext.sqlalchemy import db_connect
from apps.ext.sqlalchemy.models import Atom
from apps.modules.common.schemas.common import GetPageParams, GetParams
from apps.modules.atom.schemas.atom import GetAtom, AtomSer
from apps.utils.crud import set_default_data
from apps.utils.pagination import Pagination
from apps.utils.response import Resp
from apps.utils.security import get_current_user_id

router = APIRouter(tags=["原子管理"])


@router.post('/addOne', summary="添加原子", response_model=Resp)
async def add_one(atom: GetAtom, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        atom = Atom(**atom.dict())
        set_default_data(atom, current_user_id)
        session.add(atom)

        return Resp(message="添加原子信息成功")


@router.post('/deleteById/{id}', summary="删除原子", response_model=Resp)
async def delete_by_id(id: str):
    async with db_connect.async_session() as session:
        # 删除字典
        await session.execute(select(Atom).where(Atom.id == id).delete())

        return Resp(message="删除原子信息成功")


@router.post('/updateById/{id}', summary="更新原子", response_model=Resp)
async def update_by_id(id: str, atom: GetAtom, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        atom = Atom(**atom.dict())
        atom.id = id
        set_default_data(atom, current_user_id)
        session.merge(atom)

        return Resp(message="更新原子信息成功")


@router.get('/findById/{id}', summary="查询原子", response_model=Resp)
async def find_by_id(id: str):
    async with db_connect.async_session() as session:
        atom = await session.get(Atom, id)
        atom_ser = AtomSer.dump(atom)

        return Resp(data=atom_ser, message="原子信息查询成功")


@router.get('/findList', summary="分页查询原子列表", response_model=Resp)
async def find_list(params: GetPageParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, Atom).get_page(session)
        atom_list = page_data['list']
        atom_list = Atom.dump(atom_list, many=True)
        total = page_data['total']

        atom = {"atomList": atom_list, "total": total}
        return Resp(data=atom, message="获取原子信息列表成功")


@router.get('/findAll', summary="查询所有原子", response_model=Resp)
async def find_all(params: GetParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, Atom, all=True).get_page(session)
        atom_list = page_data['list']
        atom_list = AtomSer.dump(atom_list, many=True)
        atom = {"atomList": atom_list}
        return Resp(data=atom, message="获取原子信息列表成功")