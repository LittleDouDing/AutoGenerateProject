from typing import Optional, List
from pydantic import Field, validator
from apps.ext.sqlalchemy.models import User, Systheme, Role, Menu
from apps.utils.serializer import model2schema


class GetUser(model2schema(User, exclude=["id"])):
    roleIds: Optional[List[str]] = None


class UserSer(model2schema(User)):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class UserListSer(model2schema(User)):
    roleList: List['RoleSer'] = []
    roleIds: List[str] = []
    systhemeInfo: Optional['SysthemeSer'] = None

    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class UserForm(model2schema(User, exclude=["id", "create_time", "update_time"])):
    roleIds: Optional[List[str]] = None


class GetSystheme(model2schema(Systheme, exclude=["id"])):
    pass


class SysthemeSer(model2schema(Systheme)):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class GetRole(model2schema(Role, exclude=["id"])):
    pass


class RoleSer(model2schema(Role)):
    # 日期转为2023-08-21 00:00:00格式
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class GetMenu(model2schema(Menu, exclude=["id"])):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class MenuSer(model2schema(Menu)):
    children: List['MenuSer'] = Field(default_factory=list)

    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)
