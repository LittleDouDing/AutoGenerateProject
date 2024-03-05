import os
from fastapi import UploadFile
from apps.config.docs import docs
from datetime import timedelta
from fastapi import APIRouter, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from starlette import status
from apps.ext.sqlalchemy.models import User, Systheme, Menu, RoleMenu, Role, UserRole, Atom, MenuAtom
from apps.modules.common.schemas.common import AuthDetails, UserRegister, SysthemeSer, MenuSer, UserSer
from apps.ext.sqlalchemy import db_connect
from fastapi import Depends
from apps.utils.crud import get_relationship_data, set_default_data
from apps.utils.response import Resp
from apps.utils.security import (
    authenticate_user,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    create_access_token, Token,
    get_current_user_id,
    get_password_hash
)

router = APIRouter(tags=["特殊路由管理"])


@router.post('/upload', summary="文件上传", response_model=Resp)
async def upload(file: UploadFile):
    # 上传文件目录
    upload_dir = os.path.join(docs.ROOT_PATH, 'uploads')
    path = os.path.join(upload_dir, file.filename)
    with open(path, "wb") as f:
        for line in file.file:
            f.write(line)
    data = {"path": os.path.join('uploads', file.filename)}

    return Resp(data=data, message="文件上传成功")


@router.post('/login', summary="用户登录", response_model=Resp)
async def login(auth_details: AuthDetails):
    """
    用户登录
    Args:
        auth_details: 用户登录信息
    Returns: 登录结果
    """
    async with db_connect.async_session() as session:
        # 判断用户是否存在
        user = await authenticate_user(session, auth_details.username, auth_details.password)
        token = check_user_and_generate_token(user)
        data = {"token": token}

        return Resp(data=data, message="登录成功")


@router.post('/register', summary="用户注册", response_model=Resp)
async def register(_user: UserRegister):
    """
    用户注册
    Args:
        _user: 用户注册信息
    Returns: 注册结果
    """
    _user = _user.dict()
    async with db_connect.async_session() as session:
        user = User(**_user)
        user.password = get_password_hash(user.password)
        set_default_data(user, '')
        session.add(user)
        await session.commit()
        await session.refresh(user)

        return Resp(message="注册成功")


@router.post('/docsLogin', include_in_schema=False, summary="文档登录")
async def docs_login(auth_details: OAuth2PasswordRequestForm = Depends()):
    """
    文档登录
    Args:
        auth_details: 用户登录信息
    Returns: 登录结果
    """
    async with db_connect.async_session() as session:
        # 判断用户是否存在
        user = await authenticate_user(session, auth_details.username, auth_details.password)
        token = check_user_and_generate_token(user)

        return Token(access_token=token, token_type="bearer")


@router.post('/info', summary="获取用户详细信息", response_model=Resp)
async def info(current_user_id: User = Depends(get_current_user_id)):
    async with db_connect.async_session() as session:
        user = await session.get(User, current_user_id)
        user_info = UserSer.dump(user)
        # 查询主题信息
        sys_theme = await get_relationship_data(session, user, Systheme)
        sys_theme_info = SysthemeSer.dump(sys_theme)
        # 查询菜单信息
        query = select(Menu).join(RoleMenu, RoleMenu.menu_id == Menu.id).join(Role, Role.id == RoleMenu.role_id) \
            .join(UserRole, UserRole.role_id == Role.id).where(UserRole.user_id == user.id)
        query_ = await session.execute(query)
        menu_list = query_.scalars().all()
        menu_list = await get_menu_tree(session, menu_list, None)
        menu_list = MenuSer.dump(menu_list, many=True)
        data = {"userInfo": user_info, "systhemeInfo": sys_theme_info, "menuList": menu_list}

        return Resp(data=data, message="获取用户详细成功")


async def get_menu_tree(session: AsyncSession, menu_list, parent_id):
    """
    获取菜单树
    Args:
        session: 数据库连接
        menu_list: 菜单列表
        parent_id: 父级id
    Returns: 菜单树, 菜单树序列化
    """
    tree = [menu for menu in menu_list if menu.superior_id == parent_id]
    for menu in tree:
        # 递归获取子级菜单，序列化后的子级菜单
        menu.children = await get_menu_tree(session, menu_list, menu.id)
        # 获取菜单下的按钮
        menu.atomList = await get_relationship_data(session, menu, Atom, MenuAtom)
    # 返回菜单树和序列化后的菜单树
    return tree


def check_user_and_generate_token(user):
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    # 生成token有效时间
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    # 生成token
    token = create_access_token(data={"sub": user.username}, expires_delta=access_token_expires)
    return token
