from typing import Optional, List
from pydantic import BaseModel, Field, validator
from apps.ext.sqlalchemy.models import Systheme, Menu, User, Atom
from apps.utils.serializer import model2schema
from datetime import datetime


class AuthDetails(BaseModel):
    username: str
    password: str


class UserRegister(BaseModel):
    name: Optional[str] = None
    username: str
    password: str


class SysthemeSer(model2schema(Systheme)):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class AtomSer(model2schema(Atom)):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class MenuSer(model2schema(Menu)):
    children: List['MenuSer'] = Field(default_factory=list)
    atomList: List[AtomSer] = Field(default_factory=list)

    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class UserSer(model2schema(User)):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)


class GetPageParams(BaseModel):
    """
    获取分页查询列表参数
    """
    page: int = 1
    pageSize: int = 10
    sortField: Optional[str] = None
    sortOrder: Optional[str] = None
    startDate: Optional[datetime] = None
    endDate: Optional[datetime] = None
    keywords: Optional[str] = None
    relations: Optional[str] = None


class GetParams(BaseModel):
    """
    获取全部查询列表参数
    """
    sortField: Optional[str] = None
    sortOrder: Optional[str] = None
    startDate: Optional[datetime] = None
    endDate: Optional[datetime] = None
    keywords: Optional[str] = None
    relations: Optional[str] = None
