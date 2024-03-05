import json
from sqlacodegen.codegen import CodeGenerator
from os.path import dirname, join, abspath
from sqlalchemy.schema import CreateTable
from sqlalchemy import Table, Column, text, create_engine, MetaData, DateTime, Float, Integer, JSON, String, TEXT
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.dialects.mysql import TINYINT, BIGINT

type_obj = {
    'int': Integer,
    'bigint': BIGINT,  # 存储id数据
    'tinyint': TINYINT,  # 存储很小的数字类型数据，比如性别的值(1:男;2:女)
    'float': Float,
    'string': String,
    'date': DateTime,
    'password': String,
    'email': String(256),
    'textarea': TEXT,
    'richtext': String(256),
    'url': String(256),
    'soundUrl': String(256),
    'videoUrl': String(256),
    'radio': String(256),
    'enums': JSON,
    'object': JSON,
    'enum': String(256),
    'checked': JSON,
}

length_obj = {
    'string': 256,
    'tinyint': 1,
    'password': 100
}

DATABASE_URL = 'mysql+pymysql://root:root@localhost:3306'


class TableManager:

    def __init__(self, project_name: str = 'FastapiTemplate') -> None:
        """
        Args:
            project_name: 项目的名字
        """
        self.model_path = abspath(join(dirname(__file__), f'../../{project_name}/apps/ext/sqlalchemy/models.py'))
        self.json_path = abspath(join(dirname(__file__), '../template.json'))
        self.sql_path = abspath(join(dirname(__file__), '../table.sql'))
        self.metadata = MetaData()
        self.engine = create_engine(DATABASE_URL)

    def load_from_local(self) -> None:
        """
        从本地json中心数据中加载数据，并自动创建数据库
        Returns:
        """
        try:
            with open(self.json_path) as fp:
                json_data: dict = json.loads(fp.read())
                print('json_data', json_data)
                self.generate_database_tables(json_data)
        except Exception as e:
            print(e)

    def _export_tables(self) -> None:
        """
        将数据库中的表模型导出到model_path指定的位置
        Returns:
        """
        # popen(f'sqlacodegen {getenv("DATABASE_URL")}/{database_name} > {self.model_path}')
        generator = CodeGenerator(metadata=self.metadata)
        with open(self.model_path, 'w+') as file:
            generator.render(outfile=file)
            file.seek(0)
            lines = file.readlines()
            lines.insert(1, 'from apps.utils.dict import to_dict\n')
            lines.insert(7, 'Base.to_dict = to_dict\n')
        with open(self.model_path, "w") as file:
            file.writelines(lines)

    @staticmethod
    def _handle_column(obj: dict) -> Column:
        """
        处理表的每一列（字段）
        Args:
            obj: 中心数据表中的每一列对象
        Returns: 返回处理后的列数据
        """
        column_name: str = obj.get('columnName')
        column_comment: str = obj.get('comment')
        column_type = type_obj.get(obj.get('type'))
        column_length: int = obj.get('length')
        column_type = column_type(column_length) if column_length else column_type(length_obj.get(obj.get('type')))
        is_unique: bool = obj.get('unique') is True
        is_nullable: bool = False if obj.get('required') is True else True
        column: Column = Column(
            column_name,
            column_type,
            comment=column_comment,
            nullable=is_nullable,
            unique=is_unique
        )
        if 'default' in obj:
            setattr(column, 'server_default', text(obj.get('default')))
        return column

    def _handle_foreign_table(self, curr_table: str, foreign_table: str) -> None:
        """
        Args:
            curr_table: 当前表的名称
            foreign_table: 关联表的名称
        Returns:
        """
        if foreign_table:
            table_name = f'{curr_table}_{foreign_table}'
            table = Table(table_name, self.metadata)
            id_type = type_obj.get('bigint')
            curr_table_id = Column(f'{curr_table}_id', id_type, nullable=False, comment=f'{curr_table} id')
            foreign_table_id = Column(f'{foreign_table}_id', id_type, nullable=False, comment=f'{foreign_table} id')
            table.append_column(curr_table_id)
            table.append_column(foreign_table_id)

    def _handle_table(self, table_obj: dict) -> None:
        """
        动态处理每一张表
        Args:
            table_obj: 中心数据中表的对象
        Returns:
        """
        table_name: str = table_obj.get('tableName')
        foreign_table: str = table_obj.get('foreignTable')
        id_type = type_obj.get('bigint')
        table: Table = Table(
            table_name,
            self.metadata,
            Column('id', id_type, primary_key=True, server_default=text("(UUID())"), comment='主键id')
        )
        columns: list[dict] = table_obj.get('columns')
        default_columns = [
            Column('create_user', type_obj.get('bigint'), nullable=False, comment='创建人的id'),
            Column('update_user', type_obj.get('bigint'), nullable=False, comment='创建人的id'),
            Column('create_time', type_obj.get('date'), nullable=False, comment='创建时间'),
            Column('update_time', type_obj.get('date'), nullable=False, comment='更新时间')
        ]
        for column_obj in columns:
            column: Column = self._handle_column(column_obj)
            table.append_column(column)
        for column in default_columns:
            table.append_column(column)
        self._handle_foreign_table(table_name, foreign_table)

    def _export_table_sql(self) -> None:
        base = automap_base()
        base.prepare(self.engine, reflect=True)
        lines = []
        # 遍历数据库表
        for table_name, table_obj in base.classes.items():
            # 生成表的 CREATE 语句
            create_statement = CreateTable(table_obj.__table__).compile(self.engine)
            sql = str(create_statement)
            lines.append(sql)
        # 将 SQL 语句写入文件
        with open(self.sql_path, "w") as file:
            file.writelines(lines)

    def generate_database_tables(self, table_data: dict) -> None:
        """
        动态生成所有的表
        Args:
            table_data: 数据库中所有表的数据集合
        Returns:
        """
        database_name: str = table_data['model']['projectName'] or 'test'
        query = f"SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '{database_name}'"
        if self.engine.execute(query).fetchone() is not None:
            drop_database_sql: str = f'DROP DATABASE {database_name}'
            self.engine.execute(drop_database_sql)
        create_database_sql: str = f'CREATE DATABASE {database_name}'
        self.engine.execute(create_database_sql)
        new_engine = create_engine(f"{DATABASE_URL}/{database_name}")
        self.engine = new_engine
        self.metadata.bind = new_engine
        self.metadata.drop_all()
        table_list: list[dict] = table_data['model']['tableList']
        for table_obj in table_list:
            self._handle_table(table_obj)
        self.metadata.create_all()
        self._export_tables()
        self._export_table_sql()


table_manager = TableManager()
if __name__ == '__main__':
    table_manager.load_from_local()
