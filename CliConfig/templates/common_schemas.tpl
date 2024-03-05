from apps.utils.serializer import model2schema
from pydantic import validator
from apps.ext.sqlalchemy.models import {{model_name}}


class Get{{model_name}}(model2schema({{model_name}}, exclude=["id"])):
    pass


class {{model_name}}Ser(model2schema({{model_name}})):
    @validator("update_time", allow_reuse=True)
    def update_time(cls, v):
        return str(v)

    @validator("create_time", allow_reuse=True)
    def create_time(cls, v):
        return str(v)