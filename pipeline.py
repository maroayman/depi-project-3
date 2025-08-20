from flowpipe import Node, Pipeline


class Lint(Node):
    def run(self):
        import subprocess
        result = subprocess.run(["flake8", "."], capture_output=True, text=True)
        return {"lint_output": result.stdout or "No lint errors"}


class MigrateDB(Node):
    def run(self):
        import subprocess
        result = subprocess.run(["alembic", "upgrade", "head"], capture_output=True, text=True)
        return {"migration_output": result.stdout or result.stderr}


class RunTests(Node):
    def run(self):
        import subprocess
        result = subprocess.run(["pytest"], capture_output=True, text=True)
        return {"test_output": result.stdout or "No tests available"}


if __name__ == "__main__":
    pipeline = Pipeline(name="DevPipeline")

    lint = Lint(name="Lint")
    migrate = MigrateDB(name="Migrate")
    tests = RunTests(name="Tests")

    pipeline.add_node(lint)
    pipeline.add_node(migrate)
    pipeline.add_node(tests)

    # define execution order
    lint >> migrate >> tests

    result = pipeline.run()
    print(result)