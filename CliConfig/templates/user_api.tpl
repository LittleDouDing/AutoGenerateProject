from fastapi import APIRouter
from sqlalchemy import select
from apps.ext.sqlalchemy.models import User, Systheme, Role, UserRole
from apps.modules.common.schemas.common import GetPageParams, GetParams
from apps.modules.user.schemas.user import UserForm, UserListSer, GetUser, RoleSer, SysthemeSer
from apps.ext.sqlalchemy import db_connect
from fastapi import Depends
from apps.utils.crud import get_relationship_data, set_default_data
from apps.utils.pagination import Pagination
from apps.utils.response import Resp
from apps.utils.security import get_current_user_id, get_password_hash

router = APIRouter(tags=["用户管理"])


@router.post('/addOne', summary="新增用户", response_model=Resp)
async def add_one(data: GetUser, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        data = data.dict()
        role_ids = data.pop("roleIds")
        data = User(**data)
        data.password = get_password_hash(data.password)
        # 设置默认创建人、更新人、创建时间、更新时间
        set_default_data(data, current_user_id)
        session.add(data)
        await session.commit()
        await session.refresh(data)
        # 删除用户角色关联表
        await session.execute(select(UserRole).where(UserRole.user_id == data.id).delete())
        await session.commit()
        # 添加用户角色关系
        user_role_list = handle_user_roles(role_ids, current_user_id)
        session.add_all(user_role_list)
        return Resp(message="用户添加成功")


@router.post('/deleteById/{id}', summary="删除用户", response_model=Resp)
async def delete_by_id(id: str):
    async with db_connect.async_session() as session:
        # 删除用户角色关联表
        await session.execute(select(UserRole).where(UserRole.user_id == id).delete())
        # 删除用户
        await session.execute(select(User).where(User.id == id).delete())
        return Resp(message="用户删除成功")


@router.post('/updateById/{id}', summary="更新用户", response_model=Resp)
async def update_by_id(id: str, data: UserForm, current_user_id: str = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        data = data.dict()
        role_ids = data.pop("roleIds")
        data = User(**data)
        set_default_data(data, current_user_id)
        # 更新用户
        await session.execute(select(User).where(User.id == id).update(data))
        # 删除用户角色关联表
        await session.execute(select(UserRole).where(UserRole.user_id == id).delete())
        # 添加用户角色关系
        user_role_list = handle_user_roles(role_ids, current_user_id)
        session.add_all(user_role_list)
        return Resp(message="用户信息修改成功")


@router.get('/findById/{id}', summary="根据id查询用户", response_model=Resp)
async def find_by_id(id: str):
    async with db_connect.async_session() as session:
        # 查询用户信息
        data = await session.get(User, id)
        user_ser = UserListSer.dump(data)
        # 查询用户角色信息
        role_list = await get_relationship_data(session, data, Role, UserRole)
        user_ser.roleIds = [each.id for each in role_list]
        user_ser.roleList = RoleSer.dump(role_list, many=True)
        user_ser.systhemeInfo = SysthemeSer.dump(await get_relationship_data(session, data, Systheme))

        return Resp(data=user_ser, message="获取用户信息成功")


@router.get('/findList', summary="查询用户列表", response_model=Resp)
async def find_list(params: GetPageParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, User).get_page(session)
        data_list = page_data['list']
        data_ser_list = await handle_ser_list(data_list, params, session)
        total = page_data['total']
        data = {"userList": data_ser_list, "total": total}

        return Resp(data=data, message="获取用户列表成功")


@router.get('/findAll', summary="查询所有TableName", response_model=Resp)
async def find_all(params: GetParams = Depends()):
    async with db_connect.async_session() as session:
        page_data = await Pagination(params, User, all=True).get_page(session)
        data_list = page_data['list']
        data_ser_list = await handle_ser_list(data_list, params, session)
        data = {"userList": data_ser_list}

        return Resp(data=data, message="获取TableName信息列表成功")


async def handle_ser_list(user_list: list, params, session):
    user_ser_list = []
    relations = params.relations.split(',') if params.relations else []
    for data in user_list:
        user_ser = UserListSer.dump(data)
        if 'role' in relations or '*' in relations:
            role_list = await get_relationship_data(session, data, Role, UserRole)
            user_ser.roleIds = [role.id for role in role_list]
            user_ser.roleList = RoleSer.dump(role_list, many=True)
        if 'systheme' in relations or '*' in relations:
            user_ser.systhemeInfo = SysthemeSer.dump(await get_relationship_data(session, data, Systheme))
        user_ser_list.append(user_ser)
    return user_ser_list


def handle_user_roles(role_ids: list[str], current_user_id: str):
    from datetime import datetime
    user_role_list = [UserRole(
        user_id=id,
        role_id=role_id,
        create_user=current_user_id,
        update_user=current_user_id,
        create_time=datetime.now(),
        update_time=datetime.now()
    ) for role_id in role_ids]
    return user_role_list
