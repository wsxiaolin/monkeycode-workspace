# projects/

业务项目的本地检出目录。源码不进入工作台仓库。

可提交的文件只有：

- `README.md`（本文件）
- `manifest.yaml`（项目清单）
- `.gitkeep`

其余 `projects/<name>/` 全部 gitignore。

## 登记格式

见 `manifest.yaml`。新增时追加一条，然后运行：

```bash
# 按清单克隆尚未存在的项目
../scripts/bootstrap-projects.sh
```

或在仓库根目录：

```bash
./scripts/bootstrap-projects.sh
./scripts/update-projects.sh
```

## 当前项目

| name | 远程 | 说明 |
|------|------|------|
| plweb-skill | https://github.com/NetLogo-Mobile/plweb-skill | Physics Lab Web API skills |
| pl-town | https://github.com/wsxiaolin/pl-town | Three.js isometric city |
