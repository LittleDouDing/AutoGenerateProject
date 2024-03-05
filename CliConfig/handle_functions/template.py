from os.path import dirname, join, abspath, exists
from jinja2 import Environment, FileSystemLoader
from typing import List
from json import loads
from os import makedirs
from shutil import copytree, rmtree
from CliConfig.handle_functions.table import TableManager
import re

BASE_DIR = abspath(join(dirname(__file__), '../../'))


class TemplateManager:

    def __init__(self) -> None:
        self.template_dir = abspath(join(BASE_DIR, f'CliConfig/templates'))
        self.env = Environment(loader=FileSystemLoader(self.template_dir))

    def generate_backend_modules(self, template_dir_name: str, project_dir_name: str = 'test-backend') -> None:
        source_dir = join(BASE_DIR, template_dir_name)
        target_dir = join(BASE_DIR, project_dir_name)
        if exists(target_dir):
            rmtree(target_dir)
        copytree(source_dir, target_dir)
        table_manager = TableManager()
        table_manager.load_from_local()
        json_path = join(BASE_DIR, 'CliConfig/template.json')
        with open(json_path, 'r') as file:
            json_data = loads(file.read())
            tables: List[dict] = json_data['model']['tableList']
            for table in tables:
                base_table_name = table.get('tableName')
                table_name = base_table_name
                model_name = re.sub(r"(^|_)(\w)", lambda m: m.group(2).upper(), base_table_name)
                table_commit = table.get('tableComment')
                params = {'model_name': model_name, 'table_name': table_name, 'table_commit': table_commit}
                self._render_backend(base_table_name, project_dir_name, params)

    def _render_template(self, template_name: str, params: dict = None) -> str:
        template = self.env.get_template(template_name)
        output = template.render(**params)
        return output

    def _render_backend(self, module_name: str, project_dir_name: str, params: dict = None):
        module_dir = abspath(join(BASE_DIR, f'{project_dir_name}/apps/modules'))
        module_api_path = join(module_dir, f'{module_name}/api/v1/{module_name}.py')
        module_schemas_path = join(module_dir, f'{module_name}/schemas/{module_name}.py')
        template_name = 'user' if module_name == 'user' else 'common'
        api_result = self._render_template(f'{template_name}_api.tpl', params)
        schemas_result = self._render_template(f'{template_name}_schemas.tpl', params)
        self._write_to_file(module_api_path, api_result)
        self._write_to_file(module_schemas_path, schemas_result)

    @staticmethod
    def _write_to_file(file_path: str, result: str) -> None:
        makedirs(dirname(file_path), exist_ok=True)
        with open(file_path, 'w') as file:
            file.write(result)


if __name__ == '__main__':
    template_manager = TemplateManager()
    template_manager.generate_backend_modules('FastapiTemplate')
