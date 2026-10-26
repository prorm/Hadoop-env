# CI51 Big Data Lab: practice machine in Docker

The same setup as the lab systems, on any laptop (Windows, Mac or Linux):

| | Lab machine | This container |
|---|---|---|
| OS / user | Ubuntu, `rit@rit` | Ubuntu 22.04, `rit@rit` |
| Java | OpenJDK 17.0.20.1 | OpenJDK 17.0.20.1 |
| Hadoop | `~/<USN>/hadoop-3.2.2`, standalone, set up with `source Bash.sh` | same |
| Spark | `~/spark-4.0.1-bin-hadoop3`, set up with its own `source Bash.sh` | same |
| Datasets | the lab's `DataSet` folder | `~/DataSet`, same files and names |

Hadoop and Spark are **not** on the PATH until you create and `source Bash.sh` in their folder, exactly like the lab.

## Slow PC or no Docker? Use GitHub Codespaces (runs in the browser)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/prorm/Hadoop-env)

1. Sign in to GitHub (a free account is enough).
2. *(Optional, once)* GitHub → Settings → Codespaces → Secrets → **New secret**: name `USN`, value your USN
   (e.g. `1MS24CI091`), and give it access to this repository. Without it the folder is just called `~/USN`.
3. Click the button above (or **Code → Codespaces → Create codespace on main**).
   The first start builds the lab (5-10 minutes); later starts take seconds.
4. Open a terminal (**Ctrl + `**) and practise exactly as below: `lab-help`, `cd ~/<USN>/hadoop-3.2.2`, `source Bash.sh` ...
5. When you finish, **stop the codespace** at <https://github.com/codespaces> so you don't use up your free hours.

The HDFS web UI (port 9870) and Spark UI (port 4040) open from the **Ports** tab.

**How to run every program, where the datasets are, and how to check Hadoop and Spark work:
see [PRACTICE.md](PRACTICE.md).**

## 1. One-time setup (Docker on your own laptop)

1. Install **Docker Desktop**: <https://www.docker.com/products/docker-desktop/>
   - Windows: accept "Use WSL 2" when asked, restart if it asks.
   - Mac: pick the Apple Silicon or Intel download to match your Mac.
2. Start Docker Desktop and wait until it says **Engine running**.
3. Unzip this folder somewhere simple (e.g. `Documents\bigdata-lab`).
4. Open the file `.env` in Notepad / TextEdit and put your USN in it:
   ```
   USN=1MS24CI091
   ```

## 2. Every time you practise

- **Windows:** double-click `start-lab.bat`
- **Mac / Linux:** open Terminal in this folder and run `./start-lab.sh`

The first start builds the lab (about 1 GB download, 5-10 minutes, one time only). Then you get:

```
rit@rit:~$
```

Need a second terminal? Run the start file again. `exit` closes a terminal.
To shut the lab down: `docker compose stop` in this folder (your files are kept).

## 3. What's inside

```
~/<USN>/hadoop-3.2.2          Programs 1-3 (HDFS, MapReduce): make Programs/<name> here
~/spark-4.0.1-bin-hadoop3     Programs 4-6 (Spark): work inside this folder
~/DataSet/                    the lab's dataset files (+ WordCount Input.txt, Retail Transactions.txt)
~/shared/                     same as the "shared" folder on your laptop
```

The dataset names contain spaces, so copy them to a short name with quotes:
`cp ~/DataSet/"Sales Records _Input.csv" sales.csv`

## 4. Commands added for practice

| Command | What it does |
|---|---|
| `lab-help` | cheat sheet: folders, Bash.sh, commands |
| `hdfs-on` | starts a real single-node HDFS for **Program 1** and points this terminal at it (prompt shows `(hdfs)`) |
| `hdfs-off` | back to local files. **Do this before Programs 2-6** |
| `hdfs-stop` | stops HDFS |
| `lab-reset` | back to exam-start state: moves everything you made into `~/lab-backup-<time>/` and wipes HDFS |
| `lab-fresh-install` | practise installing: hides Hadoop/Spark and downloads the official tarballs to `~/Downloads`. `lab-fresh-install --restore` undoes it |

HDFS web UI (after `hdfs-on`): <http://localhost:9870>. Spark UI while a job runs: <http://localhost:4040>.

## Troubleshooting

- **"Docker is not running"**: open Docker Desktop, wait for *Engine running*.
- **`hadoop: command not found`**: run `source Bash.sh` inside `hadoop-3.2.2` in this terminal.
- **`Input path does not exist: hdfs://localhost:9000/...`**: this terminal is in HDFS mode; run `hdfs-off`.
- **`Output directory ... already exists`**: `rm -r output` (or the folder you named).
- **`No such file or directory` for a dataset**: the name has spaces; put it in quotes.
- **Start completely fresh** (deletes all your work): `docker compose down -v`, then start again.
- **Changed your USN in `.env`?** Run `docker compose up -d` and the folder is renamed.
- **Slow or killed jobs**: Docker Desktop → Settings → Resources → Memory at least 4 GB.

---

## For whoever shares this with the class

Students can build the image themselves (the start script does it, downloading Hadoop and Spark
from the Apache archive, checked against the official SHA-512). It's faster to publish it once:

1. Push this folder to a GitHub repository (branch `main`).
2. The included workflow (`.github/workflows/publish.yml`) builds it for Intel/AMD **and Apple Silicon**
   and publishes `ghcr.io/<your-github-name>/bigdata-lab:latest`.
3. Make the package public: GitHub → your profile → Packages → bigdata-lab → Package settings → Change visibility.
4. In `.env`, set `LAB_IMAGE=ghcr.io/<your-github-name>/bigdata-lab:latest` (or edit `docker-compose.yml`).

`WordCount Input.txt` and `Retail Transactions.txt` are not in the lab's DataSet archive: they were
added for practice. The retail file reproduces the lab's expected output for Program 7.
